import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixelpioneer_cpplink/customer/customer_homePage.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CustomerQuickScan extends StatefulWidget {
  const CustomerQuickScan({Key? key}) : super(key: key);

  @override
  _CustomerQuickScanState createState() => _CustomerQuickScanState();
}

class _CustomerQuickScanState extends State<CustomerQuickScan> {
  TextEditingController qrController = TextEditingController();
  String dropdownValue = "";
  List<String> userParcel = [];

  void triggerUpdateListParcel() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('parcel').get();

    setState(() {
      userParcel = querySnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  void initState() {
    super.initState();

    // Listen to real-time changes on Firestore (parcel collection)
    FirebaseFirestore.instance
        .collection('parcel')
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added ||
            change.type == DocumentChangeType.modified ||
            change.type == DocumentChangeType.removed) {
          print('Change type: ${change.type}, Document ID: ${change.doc.id}');
          triggerUpdateListParcel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 195, 44, 1),
        centerTitle: true,
        title: const Text(
          'Quick Scan',
          style: TextStyle(
            fontFamily: 'roboto',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/customer_home');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Show the generated QR at CPP to easily get your parcel detail.',
              style: TextStyle(
                color: Color(0xFF050505),
                fontSize: 17,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                height: 0.00,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Column(
              children: [
                const Text('Parcel QR',
                    style: TextStyle(
                      color: Color(0xFF050505),
                      fontSize: 17,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                      height: 0.00,
                    )),
                const SizedBox(
                  height: 12,
                ),
                dropdownValue.isNotEmpty
                    ? Center(
                        child: QrImageView(
                          data: dropdownValue,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      )
                    : Center(
                        child: Container(
                          height: 200,
                          width: 200,
                          color: const Color.fromARGB(255, 214, 214, 214),
                          child: const Center(
                            child: Text(
                              "No Tracking Number",
                              style: TextStyle(
                                color: Color(0xFF050505),
                                fontSize: 17,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w400,
                                height: 0.00,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(
                  height: 30,
                ),
                const Text('Select Your Parcel Track Number : ',
                    style: TextStyle(
                      color: Color(0xFF050505),
                      fontSize: 17,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                      height: 0.00,
                    )),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 250,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      items: userParcel.map((parcel) {
                        return DropdownMenuItem<String>(
                          child: Text(parcel),
                          value: parcel,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      isExpanded: true,
                      elevation: 8,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Customer Quick Scan',
    initialRoute: '/customer_quick_scan',
    routes: {
      '/customer_quick_scan': (context) => const CustomerQuickScan(),
      '/customer_home': (context) => const CustomerHomepage (), 
    },
  ));
}
