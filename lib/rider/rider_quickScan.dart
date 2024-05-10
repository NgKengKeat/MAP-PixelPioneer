
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pixelpioneer_cpplink/controller.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../main.dart';

class RiderQuickScan extends StatefulWidget {
  const RiderQuickScan({super.key});

  @override
  State<RiderQuickScan> createState() => _RiderQuickScanState();
}

class _RiderQuickScanState extends State<RiderQuickScan> {
  TextEditingController qrController = TextEditingController();
  List<String> userParcelIds = [];
  var dropdownValue = dropdownValues;

  triggerUpdateListParcel() async {
    await getArrivedParcel(currentUserID);
    await updateListParcel();

    if (mounted) {
      setState(() {
        user_parcel;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchParcelIds();
  }
  void fetchParcelIds() {
    FirebaseFirestore.instance
      .collection('parcels')
      .where('user_id', isEqualTo: currentUserID) // Assuming currentUserID is defined
      .where('status', isEqualTo: 'arrived')
      .snapshots().listen((snapshot) {
        List<String> parcelIds = [];
        for (var doc in snapshot.docs) {
          parcelIds.add(doc.data()['parcel_id'] ?? '');
          
        }
        setState(() {
          userParcelIds = parcelIds;
          dropdownValue = parcelIds.isNotEmpty ? parcelIds.first : null;
        });
         triggerUpdateListParcel();
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
            Icons.arrow_back, // You can replace this with your custom logo
            color: Colors.white, // Icon color
          ),
          onPressed: () {
            // Navigator.of(context).pushReplacementNamed('/');
            Navigator.of(context).pushReplacementNamed('/rider_home');
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                      'Show the generated Qr at CPP to easily get your parcel detail.',
                      style: TextStyle(
                        color: Color(0xFF050505),
                        fontSize: 17,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w400,
                        height: 0.00,
                      )),
                  const SizedBox(
                    height: 50,
                  ),
                  Column(
                    children: [
                      Column(children: [
                        const Text('Parcel Qr',
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
                        dropdownValue != ""
                            ? Center(
                                child: QrImageView(
                                  data: dropdownValue.toString(),
                                  version: QrVersions.auto,
                                  size: 200.0,
                                ),
                              )
                            : Center(
                                child: Container(
                                    height: 200,
                                    width: 200,
                                    color: const Color.fromARGB(
                                        255, 214, 214, 214),
                                    child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "No Tracking Number",
                                            style: TextStyle(
                                              color: Color(0xFF050505),
                                              fontSize: 17,
                                              fontFamily: 'Lexend',
                                              fontWeight: FontWeight.w400,
                                              height: 0.00,
                                            ),
                                            textAlign: TextAlign.center,
                                          )
                                        ])),
                              )
                      ]),
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
                        
                            items: user_parcel.map((String parcel) {
                              return DropdownMenuItem<String>(
                                child: Text(parcel),
                                value: parcel,
                              );
                  //           items: userParcelIds.map<DropdownMenuItem<String>>((String value) {
                  // return DropdownMenuItem<String>(
                  //   value: value,
                  //   child: Text(value),
                  // );

                            }).toList(),
                            onChanged: (value) => setState(() {
                              dropdownValue = value;
                            }),
                            isExpanded: true,
                            elevation: 8, // Set the position to below
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
