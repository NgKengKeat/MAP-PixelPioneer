import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixelpioneer_cpplink/customer/customer_homePage.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RiderQuickScan extends StatefulWidget {
  const RiderQuickScan({Key? key}) : super(key: key);

  @override
  _RiderQuickScanState createState() => _RiderQuickScanState();
}

class _RiderQuickScanState extends State<RiderQuickScan> {
  TextEditingController qrController = TextEditingController();
  String dropdownValue = "";
  List<String> parcelTrackingIds = [];
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  String? selectedTrackingId;

  Future<void> fetchTrackingIds(String id) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('parcels')
          .where('user_id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<String> trackingIds = [];

        for (var doc in querySnapshot.docs) {
          String trackingId = doc['tracking_id'];
          if (trackingId != null) {
            trackingIds.add(trackingId);
          }
        }

        setState(() {
          parcelTrackingIds = trackingIds;
        });
      } else {
        setState(() {
          parcelTrackingIds = [];
        });
      }
    } catch (e) {
      print('Error fetching tracking IDs: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTrackingIds(userId!);
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
            Navigator.of(context).pushReplacementNamed('/rider_home');
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
                selectedTrackingId != null && selectedTrackingId!.isNotEmpty
                    ? Center(
                        child: QrImageView(
                          data: selectedTrackingId!,
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
                  child: DropdownButtonFormField<String>(
                    value: selectedTrackingId,
                    items: parcelTrackingIds.map((parcel) {
                      return DropdownMenuItem<String>(
                        value: parcel,
                        child: Text(parcel),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedTrackingId = newValue;
                      });
                    },
                    isExpanded: true,
                    elevation: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}