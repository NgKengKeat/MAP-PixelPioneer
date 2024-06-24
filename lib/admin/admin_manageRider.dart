import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pixelpioneer_cpplink/controller.dart';


class ManageRiderPage extends StatefulWidget {
  const ManageRiderPage({super.key});

  @override
  State<ManageRiderPage> createState() => _ManageRiderPageState();
}

class _ManageRiderPageState extends State<ManageRiderPage> {
  String riderStatus = 'All';
  String searchInput = "";
  bool isLoading = false;
  int riderCounter = 0;
  int delivery_counter = 0;

  dynamic allRider_list_user = allRider_parcel_list_user;
  

  dynamic listDeliveringParcel = listParcelID ;
  
  @override
  void initState() {
    super.initState();
    userNameList();
    

    print('Initial parcel list user data: $allRider_parcel_list_user');
    if (allRider_parcel_list_user != null && allRider_parcel_list_user.isNotEmpty) {
      allRider_list_user = List.from(allRider_parcel_list_user); // Make sure parcel_data is not empty
      print('All Rider User List initialized: $allRider_list_user');
    } else {
      print('Rider User List data is empty');
    }

  }

  
  @override
  void dispose() {
    super.dispose();
  }

  void sortRiderName() {
    allRider_list_user = List.from(allRider_list_user);
    print(allRider_list_user);
    setState(() {
      if (riderCounter == 1) {
        allRider_list_user.sort((a, b) => (a['name'] as String)
            .compareTo(b['name'] as String));
      } else {
        allRider_list_user.sort((a, b) => (b['name'] as String)
            .compareTo(a['name'] as String));
      }
    });
  }

  void sortRiderStatus() {
    allRider_list_user = List.from(allRider_list_user);
    setState(() {
      if (delivery_counter == 1) {
        allRider_list_user.sort(
            (a, b) => (a['status'] as String).compareTo(b['status'] as String));
      } else {
        allRider_list_user.sort(
            (a, b) => (b['status'] as String).compareTo(a['status'] as String));
      }
    });
  }

  void filterRider() {
    allRider_list_user = List.from(allRider_list_user);
    riderCounter = 0;
    setState(() {
      //has input
      if (searchInput.isNotEmpty) {
        //has input, status all
        if (riderStatus == 'All') {
          allRider_list_user = allRider_parcel_list_user
              .where((element) =>
                  (element['rider_id'] != null) &&
                  (element['name']!
                      .toLowerCase()
                      .contains(searchInput.toLowerCase())))
              .toList();
          return;
        } else
        //has input, status is not all
        {
          allRider_list_user = allRider_parcel_list_user
              .where((element) =>
                  (element['rider_id'] != null) &&
                  ((element['name']!
                      .toLowerCase()
                      .contains(searchInput.toLowerCase()))) &&
                  (element['status'].contains(riderStatus.toLowerCase())))
              .toList();
          return;
        }
        // has no input
      } else {
        //has no input, status is all
        if (riderStatus == 'All') {
          allRider_list_user = allRider_parcel_list_user;
          return;
        } else {
          //has no input, status is not all
          allRider_list_user = allRider_parcel_list_user
              .where((element) =>
                  (element['rider_id'] != null) &&
                  (element['status'].contains(riderStatus.toLowerCase())))
              .toList();
          return;
        }
      }
    });
  }

  // Fetch parcel details function
Future<List<String>> fetchParcelDetails(List<dynamic> parcelIds) async {
  List<String> parcels = [];
  await Future.forEach(parcelIds, (parcelId) async {
    DocumentSnapshot parcelSnapshot = await FirebaseFirestore.instance
        .collection('parcels')
        .doc(parcelId)
        .get();
    if (parcelSnapshot.exists) {
      Map<String, dynamic> parcelData = parcelSnapshot.data() as Map<String, dynamic>;
      parcels.add(parcelData['tracking_id']);
    }
  });
  return parcels;
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(250, 195, 44, 1),
          centerTitle: true,
          title: const Text(
            'Rider',
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
              color: Colors.white, // Icon color
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/admin_home', (route) => false);
            },
          ),
        ),
        body: ListView(
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Column(
              children: [
                Row(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.black),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: TextField(
                                onChanged: (val) {
                                  setState(() {
                                    searchInput = val;
                                    filterRider();
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Search Rider...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: isLoading == true
                            ? null
                            : () async {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Filter Rider Status by'),
                                        insetPadding: EdgeInsets.zero,
                                        content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                title: const Text('All'),
                                                onTap: () {
                                                  setState(() {
                                                    riderStatus = 'All';
                                                    filterRider();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                title: const Text('Delivering'),
                                                onTap: () {
                                                  setState(() {
                                                    riderStatus = 'Delivering';
                                                    filterRider();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                title: const Text('Idle'),
                                                onTap: () {
                                                  setState(() {
                                                    riderStatus = 'Idle';
                                                    filterRider();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                title: const Text('Offline'),
                                                onTap: () {
                                                  setState(() {
                                                    riderStatus = 'Offline';
                                                    filterRider();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ]),
                                      );
                                    });
                              },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            width: 130, 
                            height: 40,
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                              color: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  width: 1.50,
                                  color: Colors.green, // Border color
                                ),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            // if loading show indicator(optional)
                            child: isLoading == true
                                ? const CircularProgressIndicator()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.sort,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                          width:
                                              5), 
                                      Text(
                                        riderStatus,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontSize: 15,
                                          fontFamily: 'Lexend',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                  child: Table(
                    border: TableBorder.all(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      width: 2,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(3),
                      ),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(4),
                      2: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD233),
                        ),
                        children: [
                          const TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Rider Detail',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        riderCounter++;
                                        riderCounter = riderCounter % 2;
                                        sortRiderName();
                                        print('Rider Counter: ${riderCounter}');
                                      });
                                    },
                                    child: riderCounter == 0
                                        ? const Icon(Icons.arrow_downward_rounded)
                                        : const Icon(Icons.arrow_upward_rounded),
                                  )
                                ],
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Rider Status',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Lexend',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        delivery_counter++;
                                        delivery_counter = delivery_counter % 2;
                                        sortRiderStatus();
                                      });
                                    },
                                    child: delivery_counter == 0
                                        ? const Icon(Icons.arrow_downward_rounded)
                                        : const Icon(Icons.arrow_upward_rounded),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (var rowUser in allRider_list_user)
                        TableRow(
                          decoration: BoxDecoration(
                            color: allRider_list_user.indexOf(rowUser) % 2 == 0
                                ? const Color.fromARGB(255, 255, 245, 211)
                                : null,
                          ),
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      (allRider_list_user.indexOf(rowUser) + 1)
                                          .toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Lexend',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // if (rowUser['user'] != null &&
                                  //     rowUser['user']['name'] != null)
                                    Text(
                                      rowUser['name'],
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontFamily: 'Lexend',
                                      ),
                                    ),
                                  // if (rowUser['user'] != null &&
                                  //     rowUser['user']['phone'] != null)
                                    Text(
                                      rowUser['phone'],
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontFamily: 'Lexend',
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    // for (var ParceIDList in listDeliveringParcel)
                                    //   if (ParceIDList != null &&
                                    //       ParceIDList.length > 0)
                                    // if (rowUser['booking'] != null && rowUser['booking'].length >0)
                                    // for (var booking in rowUser['booking'])
                                    // if (booking['parcelList'] != null && booking['parcelList'].length >0)
                                    //     Column(
                                    //       crossAxisAlignment:
                                    //           CrossAxisAlignment.start,
                                    //       children: [
                                    //         const Text(
                                    //           "Delivering parcels :",
                                    //           style: TextStyle(
                                    //             color: Colors.black,
                                    //             fontSize: 14,
                                    //             fontWeight: FontWeight.normal,
                                    //             fontFamily: 'Lexend',
                                    //           ),
                                    //         ),

                                    // for (var ParcelId in booking['parcelList'])
                                    //         Text(
                                    //           ParcelId,
                                    //           style: const TextStyle(
                                    //             color: Colors.black,
                                    //             fontSize: 15,
                                    //             fontFamily: 'Lexend',
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     )
                                  ],
                                ),
                              ),
                            ),
                            TableCell(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                rowUser['status'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontFamily: 'Lexend',
                                ),
                              ),
                            )),
                          ],
                        ),
                    ],
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
