import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pixelpioneer_cpplink/delivery/delivery_proofDeliver.dart';
import 'package:pixelpioneer_cpplink/delivery/delivery_qrPage.dart';
import '../controller.dart';
import '../main.dart';

List<dynamic> riderParcelList = [];
List<dynamic> riderParcelListD = [];
var requestedParcelList = [];
String lengthString = "";
final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
Timer? _timer;


class DeliveryList extends StatefulWidget 
{
  const DeliveryList({super.key});

  @override
  State<DeliveryList> createState() => _DeliveryListState();
}

class _DeliveryListState extends State<DeliveryList> 
{
  
  Future<void> selectParcel(int index) async 
  {
    booking_index = index;
    Navigator.pushReplacementNamed(context, '/delivery_proof');
  }

  Future<void> selectParcelD(int index) async 
  {
    booking_index = index;
     Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DeliveryProofDelivery()),
    );
  }


  Future<void> getRiderParcel(String riderId) async 
  {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  QuerySnapshot querySnapshot = await firestore
      .collection('booking')
      .where('rider_id', isEqualTo: riderId)
      .where('booking_status', isEqualTo: 'ongoing') 
      .get();

  
   riderParcelList = querySnapshot.docs.map((doc) => doc.data()).toList();

  // print('Fetched rider parcels: $riderParcelListD');
}

Future<void> getRiderParcelD(String riderId) async 
  {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  QuerySnapshot querySnapshot = await firestore
      .collection('booking')
      .where('rider_id', isEqualTo: riderId)
      .where('booking_status', isEqualTo: 'delivered') 
      .get();

  
   riderParcelListD = querySnapshot.docs.map((doc) => doc.data()).toList();

  // print('Fetched rider parcels: $riderParcelList');
}


void fetchData() async 
{
  await getRiderParcel(currentUserID);
  lengthString=riderParcelList.length.toString();
}
  

Future<void> cancelParcelOngoing(int index) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String trackingId = riderParcelList[index]['tracking_id'];

  QuerySnapshot bookingSnapshot = await firestore.collection('booking')
      .where('tracking_id', isEqualTo: trackingId)
      .get();


  if (bookingSnapshot.docs.isNotEmpty) {

    for (QueryDocumentSnapshot doc in bookingSnapshot.docs) {
      // Update each document found
      await doc.reference.update({
        'booking_status': 'cancelled',
        'picture_url':null,
        'rider_id': null,
      });
    }


    await getRiderParcel(currentUserID);
    
    QuerySnapshot riderSnapshot = await firestore.collection('riders')
        .where('rider_id', isEqualTo: currentUserID)
        .get();


    if (riderSnapshot.docs.isNotEmpty) {

      for (QueryDocumentSnapshot doc in riderSnapshot.docs) {
  
        await doc.reference.update({
          'status': 'idle',
        });
      }

         setState(() {
        fetchOngoingParcels();
        fetchData();
      });
      
      // print('Parcel cancelled and rider status updated to idle');
    } else {
      // print('No rider documents matched the query');
    }
  } else {
    // print('No booking documents matched the query');
  }
}

  Future<void> fetchOngoingParcels() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot snapshot = await firestore
        .collection('booking')
        .where('rider_id', isEqualTo: currentUserID)
        .where('booking_status', isEqualTo: 'ongoing')
        .get();

    setState(() {
      rider_parcel_list_ongoing = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }


  Future<void> fetchDeliveredParcels() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot snapshot = await firestore
        .collection('booking')
        .where('rider_id', isEqualTo: currentUserID)
        .where('booking_status', isEqualTo: 'delivered')
        .get();

    setState(() {
      rider_parcel_list_delivered = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }


Future<void> cancelParcelDelievered(int index) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String trackingId = riderParcelListD[index]['tracking_id'];

  QuerySnapshot bookingSnapshot = await firestore.collection('booking')
      .where('tracking_id', isEqualTo: trackingId)
      .get();


  if (bookingSnapshot.docs.isNotEmpty) {

    for (QueryDocumentSnapshot doc in bookingSnapshot.docs) {
      // Update each document found
      await doc.reference.update({
        'booking_status': 'cancelled',
        'picture_url':null,
        'rider_id': null,
      });
    }

     await getRiderParcel(currentUserID);
    
    QuerySnapshot riderSnapshot = await firestore.collection('riders')
        .where('rider_id', isEqualTo: currentUserID)
        .get();


    if (riderSnapshot.docs.isNotEmpty) {

      for (QueryDocumentSnapshot doc in riderSnapshot.docs) {
  
        await doc.reference.update({
          'status': 'idle',
        });
      }
    }

     setState(() {
        fetchDeliveredParcels();
        fetchData();
      });
      
      // print('Parcel cancelled and rider status updated to idle');
    } else {
      // print('No rider documents matched the query');
    }
}

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }


 void goToViewPage(String id) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QrCodePage(id: id),
    ),
  );
}



  @override
  // ignore: must_call_super
  void initState() 
  {
    super.initState();
    fetchData();
    
    getRiderParcel(currentUserID);
    getRiderParcelD(currentUserID);
    fetchOngoingParcels();
    fetchDeliveredParcels();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(248, 134, 41, 1),
          centerTitle: true,
          title: const Text(
            'Deliveries',
            style: TextStyle(
              fontFamily: 'roboto',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon
          (
              Icons.arrow_back, 
              color: Colors.white, 
          ),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/delivery_homepage');
            },
          ),
        ),
        body: ListView(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text
                  (
                    'My Deliveries',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 38,
                      fontFamily: 'Montagu Slab',
                      fontWeight: FontWeight.w400,
                      height: 0.00,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Total Deliveries: ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 17,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                      Text(
                        lengthString,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 17,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  /////////////////
////////////////////////////////////////

///////////////////////////////////////
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 20,
                    child: const Text(
                      'Ongoing',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 17,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0.00,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.separated
                  (
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: rider_parcel_list_ongoing.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 40, left: 40),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 1),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(62, 229, 188, 188),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (index + 1).toString(),
                                  style: const TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 17,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    height: 0.00,
                                  ),
                                ),
                                Row(
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    // children: [
                                    //   for (var i
                                    //       in rider_parcel_list_ongoing[index]
                                    //           ['booking_parcel'])
                                    //     if (i['parcel']['status'] != 'delivered')
                                    //       QrImageView(
                                    //         data: i['parcel_id'],
                                    //         version: QrVersions.auto,
                                    //         size: 100.0,
                                    //       ),
                                    // ],
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          // updateCurrentBookingList(
                                          //     rider_parcel_list_ongoing[index]
                                          //         ['booking_parcel']);
                                          goToViewPage(rider_parcel_list_ongoing[index]['tracking_id']);
                                          //           ['booking_parcel']);
                                        },
                                        child: const Text(
                                          'View Parcel Qr Code : ',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 17,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                            height: 0.00,
                                          ),
                                        ),
                                      )
                                    ]),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Column(
                                      children: [
                                        Text(
                                          'Track Num. : ',
                                          style: TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 17,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                            height: 0.00,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        //for (var i in rider_parcel_list_ongoing[index].value)
                                        Text(
  rider_parcel_list_ongoing[index]['tracking_id'],
  style: const TextStyle(
    color: Color(0xFF333333),
    fontSize: 17,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    height: 1.2, 
  ),
)

                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Name : ',
                                      style: TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 17,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0.00,
                                      ),
                                    ),
                                    Text(
                                      rider_parcel_list_ongoing[index]
                                
                                          ['name'],
                                      style: const TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 17,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0.00,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Phone : ',
                                      style: TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 17,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0.00,
                                      ),
                                    ),
                                    Text(
                                      rider_parcel_list_ongoing[index]['phone'],
                                      style: const TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 17,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0.00,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Address : ',
                                      style: TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 17,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0.00,
                                      ),
                                    ),
                                    Text(
                                      rider_parcel_list_ongoing[index]
                                              ['address'] ??
                                          'MA1,KTDI',
                                      style: const TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 17,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0.00,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                rider_parcel_list_ongoing[index]
                                            ['booking_status'] ==
                                        'ongoing'
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          GestureDetector
                                          (
                                            onTap: () {
                                               cancelParcelOngoing(index);

                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 100,
                                                  height: 50,
                                                  decoration: ShapeDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 174, 44, 44),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      side: const BorderSide(
                                                        width: 1.50,
                                                        color: Color
                                                            .fromARGB(
                                                            255, 174, 44, 44),
                                                      ),
                                                    ),
                                                    shadows: const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x3F000000),
                                                        blurRadius: 4,
                                                        offset: Offset(0, 4),
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      child: Center(
                                                        child: Text(
                                                          'Cancel',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: Color
                                                                .fromARGB(255,
                                                                255, 255, 255),
                                                            fontSize: 15,
                                                            fontFamily:
                                                                'Lexend',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              selectParcel(index);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 100,
                                                  height: 50,
                                                  decoration: ShapeDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 44, 174, 48),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      side: const BorderSide(
                                                        width: 1.50,
                                                        color: Color
                                                            .fromARGB(
                                                            255, 44, 174, 48),
                                                      ),
                                                    ),
                                                    shadows: const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x3F000000),
                                                        blurRadius: 4,
                                                        offset: Offset(0, 4),
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Center(
                                                      child: Text(
                                                        'Complete',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Color
                                                              .fromARGB(255,
                                                              255, 255, 255),
                                                          fontSize: 15,
                                                          fontFamily: 'Lexend',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          const Text(
                                            'Status : ',
                                            style: TextStyle(
                                              color: Color(0xFF333333),
                                              fontSize: 17,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              height: 0.00,
                                            ),
                                          ),
                                          Text(
                                            rider_parcel_list_ongoing[index]
                                                ['booking_status'],
                                            style: const TextStyle(
                                              color: Color(0xFF333333),
                                              fontSize: 17,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              height: 0.00,
                                            ),
                                          )
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: const Text(
                      'Delivered',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 17,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 0.00,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: rider_parcel_list_delivered.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(right: 40, left: 40, bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 1),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (index + 1).toString(),
                                  style: const TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 17,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    height: 0.00,
                                  ),
                                ),
                                // Row(
                                //     // mainAxisAlignment: MainAxisAlignment.center,
                                //     children: [
                                //       InkWell(
                                //         onTap: () {
                                //           updateCurrentBookingList(
                                //               rider_parcel_list_delivered[index]
                                //                   ['booking_parcel']);
                                //           //           );
                                //           goToViewPage();
                                //           //           ['booking_parcel']);
                                //         },
                                //         child: Text(
                                //           'View Parcel Qr Code : ',
                                //           style: TextStyle(
                                //             color: Colors.blue,
                                //             fontSize: 17,
                                //             fontFamily: 'Roboto',
                                //             fontWeight: FontWeight.w400,
                                //             height: 0.00,
                                //           ),
                                //         ),
                                //       )
                                //     ]
                                //     // children: [
                                //     //   for (var i
                                //     //       in rider_parcel_list_delivered[index]
                                //     //           ['booking_parcel'])
                                //     //     if (i['parcel']['status'] != 'delivered')
                                //     //       QrImageView(
                                //     //         data: i['parcel_id'],
                                //     //         version: QrVersions.auto,
                                //     //         size: 100.0,
                                //     //       ),
                                //     // ],
                                //     ),
                                 Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Column(
                                      children: [
                                        Text(
                                          'Track Num. : ',
                                          style: TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 17,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                            height: 0.00,
                                          ),
                                        ),
                                      ],
                                    ),
                                  Column(
  children: [
    Text(
      rider_parcel_list_delivered[index]['tracking_id'],
      style:const TextStyle
      (
        color: Color(0xFF333333),
        fontSize: 17,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
    ),
  ],
)

                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Name : ',
                                      style: TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 17,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0.00,
                                      ),
                                    ),
                                    Text(
                                      rider_parcel_list_delivered[index]
                                             
                                          ['name'],
                                      style: const TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 17,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0.00,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Phone : ',
                                      style: TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 17,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0.00,
                                      ),
                                    ),
                                    Text(
                                      rider_parcel_list_delivered[index]
                                          ['phone'],
                                      style: const TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 17,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0.00,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Address : ',
                                      style: TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 17,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0.00,
                                      ),
                                    ),
                                    Text(
                                      rider_parcel_list_delivered[index]
                                              ['address'] ??
                                          'MA1,KTDI',
                                      style: const TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 17,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 0.00,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                               if (rider_parcel_list_delivered[index]['booking_status'] == 'delivered')
                                Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              cancelParcelDelievered(index);

                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 100,
                                                  height: 50,
                                                  decoration: ShapeDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 174, 44, 44),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      side: const BorderSide(
                                                        width: 1.50,
                                                        color: Color
                                                            .fromARGB(
                                                            255, 174, 44, 44),
                                                      ),
                                                    ),
                                                    shadows: const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x3F000000),
                                                        blurRadius: 4,
                                                        offset: Offset(0, 4),
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      child: Center(
                                                        child: Text(
                                                          'Cancel',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: Color
                                                                .fromARGB(255,
                                                                255, 255, 255),
                                                            fontSize: 15,
                                                            fontFamily:
                                                                'Lexend',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              selectParcelD(index);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 100,
                                                  height: 50,
                                                  decoration: ShapeDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 44, 174, 48),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      side: const BorderSide(
                                                        width: 1.50,
                                                        color: Color
                                                            .fromARGB(
                                                            255, 44, 174, 48),
                                                      ),
                                                    ),
                                                    shadows: const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x3F000000),
                                                        blurRadius: 4,
                                                        offset: Offset(0, 4),
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Center(
                                                      child: Text(
                                                        'Complete',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Color
                                                              .fromARGB(255,
                                                              255, 255, 255),
                                                          fontSize: 15,
                                                          fontFamily: 'Lexend',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (rider_parcel_list_delivered[index]['booking_status'] == 'accepted') 
                                      Row(
                                        children: [
                                          const Text(
                                            'Status : ',
                                            style: TextStyle(
                                              color: Color(0xFF333333),
                                              fontSize: 17,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              height: 0.00,
                                            ),
                                          ),
                                          Text(
                                            rider_parcel_list_delivered[index]
                                                ['booking_status'],
                                            style: const TextStyle(
                                              color: Color(0xFF333333),
                                              fontSize: 17,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              height: 0.00,
                                            ),
                                          )
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
