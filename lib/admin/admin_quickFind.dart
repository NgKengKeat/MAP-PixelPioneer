import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller.dart';

class AdminQuickFind extends StatefulWidget {
  const AdminQuickFind({super.key});

  @override
  State<AdminQuickFind> createState() => _AdminQuickFindState();
}

class _AdminQuickFindState extends State<AdminQuickFind> {
  bool isLoading = false;
  TextEditingController _qrResult = TextEditingController();

  // Future<void> checkParcelAndRedirect(String parcelId) async {
  //   setState(() => isLoading = true);
  //   try {
  //     DocumentSnapshot parcelSnapshot = await FirebaseFirestore.instance
  //         .collection('parcels')
  //         .doc(parcelId)
  //         .get();

  //     if (parcelSnapshot.exists) {
  //       print("Parcel ID is found: $parcelId");
  //       Navigator.of(context).pushReplacementNamed('/admin_quickFindResult');
  //     } else {
  //       Fluttertoast.showToast(
  //         msg: "The parcel ID does not exist!",
  //       );
  //       print("Parcel ID is not found: $parcelId");
  //     }
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: "Error: $e");
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }

   checkParcelAndredirect(String parcel_id) async {
    await findParcel(parcel_id);
    if (findParcelStatus) {
      print("parcel id is found");
      Navigator.of(context).pushReplacementNamed('/admin_quickFindResult');
    } else {
      Fluttertoast.showToast(
        msg: "The parcel ID do not exist!",
      );
      print("parcel id is not found");
    }
  }


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 195, 44, 1),
        centerTitle: true,
        title: const Text(
          'Quick Find',
          style: TextStyle(
            fontFamily: 'roboto',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, // You can replace this with your custom logo
            color: Colors.white, // Icon color
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/admin_home', (route) => false);
          },
        ),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Scan Parcel Qr code to easily get the parcel detail.',
                        style: TextStyle(
                          color: Color(0xFF050505),
                          fontSize: 17,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w400,
                          height: 0.00,
                        )),
                    const SizedBox(height: 20),
                    Container(
                      width: 270,
                      height: 270,
                      child: Stack(
                        children: [
                          MobileScanner(
                            fit: BoxFit.cover,
                            controller: MobileScannerController(
                              detectionSpeed: DetectionSpeed.noDuplicates,
                              facing: CameraFacing.back,
                              torchEnabled: false,
                            ),
                            onDetect: (capture) async {
                              final List<Barcode> barcodes = capture.barcodes;
                              for (var barcode in barcodes) {
                                _qrResult.text = barcode.rawValue ?? '';
                              }
                              isLoading = true;
                              setState(() {});
                              checkParcelAndredirect(_qrResult.text);
                              // await findParcel(_qrResult.text);
                              isLoading = false;
                            },
                          ),
                          QRScannerOverlay(
                            scanAreaSize:
                                const Size(310, 310), // Adjust the size as needed
                            overlayColor:
                                const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text('Parcel Track number',
                        style: TextStyle(
                          color: Color(0xFF050505),
                          fontSize: 17,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w400,
                          height: 0.00,
                        )),
                    const SizedBox(
                      height: 10,
                    ),

                    // ),

                    Center(
                      child: SizedBox(
                        width: 230,
                        child: TextFormField(
                          // readOnly: true,
                          autofocus: true,
                          decoration: const InputDecoration(
                            label: Text('QR Results'),
                            border: OutlineInputBorder(
// ({Color color = const Color(0xFF000000), double width = 1.0, BorderStyle style = BorderStyle.solid, double strokeAlign = strokeAlignInside})
                                borderSide: BorderSide(
                              color: Colors.black,
                            )),
                          ),
                          controller: _qrResult,
                          onChanged: (value) async {
                            isLoading = true;
                            setState(() {});
                            checkParcelAndredirect(value);
                            // await findParcel(value);
                            isLoading = false;
                          },
                        ),
                      ),
                    )
                  ],
                ),
              )),
            ],
          ),
          // Loading indicator overlay
          if (isLoading)
            Container(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LottieBuilder.asset('assets/yellow_loading.json'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
