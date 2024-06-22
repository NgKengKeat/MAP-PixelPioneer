import 'package:flutter/material.dart';
import '../controller.dart';
import '../main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RiderCheckParcel extends StatefulWidget 
{
  const RiderCheckParcel({super.key});

  @override
  State<RiderCheckParcel> createState() => _RiderCheckParcelState();
}

class _RiderCheckParcelState extends State<RiderCheckParcel> 
{
  String parcelStatus = 'All';
  String parcelCategory = 'My Parcel';
  String searchInput = "";
  bool isLoading = false;
  List user_list = [];
  List parcel_list = [];
  List parcel_data = [];
  List sorted_list = [];
  bool myParcel = false;
  int parcel_counter = 0;
  int delivery_counter = 0;
  String currentUserID = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() 
  {
    super.initState();
    fetchParcels();
    filterParcel();
  }

  @override
  void dispose() 
  {
    super.dispose();
  }

   Future<void> fetchParcels() async 
   {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('parcels').get();
    parcel_data = querySnapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      parcel_list = parcel_data;
      isLoading = false;
    });
    print("parcels,$parcel_list");
  }

  void sortTrackingNumber() {
    parcel_list = List.from(parcel_list);
    setState(() {
      if (parcel_counter == 1) {
        parcel_list.sort((a, b) =>
            (a['tracking_id'] as String).compareTo(b['tracking_id'] as String));
      } else {
        parcel_list.sort((a, b) =>
            (b['tracking_id'] as String).compareTo(a['tracking_id'] as String));
      }
    });
  }

  void sortDeliveryStatus() {
    parcel_list = List.from(parcel_list);
    setState(() {
      if (delivery_counter == 1) {
        parcel_list.sort(
            (a, b) => (a['status'] as String).compareTo(b['status'] as String));
      } else {
        parcel_list.sort(
            (a, b) => (b['status'] as String).compareTo(a['status'] as String));
      }
    });
  }

  void filterParcel() 
  {
    parcel_list = List.from(parcel_data);
    parcel_counter = 0;
    delivery_counter = 0;
    setState(() {
      if (parcelCategory == "My Parcel") {
        if (searchInput.isNotEmpty) {
          if (parcelStatus == 'All') {
            parcel_list = parcel_data
                .where((element) =>
                    element['user_id'] != null &&
                    element['user_id'].contains(currentUserID) &&
                    element['tracking_id']!
                        .toLowerCase()
                        .contains(searchInput.toLowerCase()))
                .toList();
            return;
          } else {
            parcel_list = parcel_data
                .where((element) =>
                    element['user_id'] != null &&
                    element['user_id'].contains(currentUserID) &&
                    element['tracking_id']!
                        .toLowerCase()
                        .contains(searchInput.toLowerCase()) &&
                    element['status'].contains(parcelStatus.toLowerCase()))
                .toList();
            return;
          }
        } else {
          if (parcelStatus == 'All') {
            parcel_list = parcel_data
                .where((element) =>
                    element['user_id'] != null &&
                    element['user_id'].contains(currentUserID))
                .toList();
            return;
          } else {
            parcel_list = parcel_data
                .where((element) =>
                    element['user_id'] != null &&
                    element['user_id'].contains(currentUserID) &&
                    element['status'].contains(parcelStatus.toLowerCase()))
                .toList();
            return;
          }
        }
      } else {
        if (searchInput.isNotEmpty) {
          if (parcelStatus == 'All') {
            parcel_list = parcel_data
                .where((element) =>
                    element['tracking_id'] != null &&
                    element['tracking_id']!
                        .toLowerCase()
                        .contains(searchInput.toLowerCase()))
                .toList();
            return;
          } else {
            parcel_list = parcel_data
                .where((element) =>
                    element['tracking_id']!
                        .toLowerCase()
                        .contains(searchInput.toLowerCase()) &&
                    element['status'].contains(parcelStatus.toLowerCase()))
                .toList();
            return;
          }
        } else {
          if (parcelStatus == 'All') {
            parcel_list = parcel_data;
            return;
          } else {
            parcel_list = parcel_data
                .where((element) =>
                    element['status'].contains(parcelStatus.toLowerCase()))
                .toList();
            return;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(250, 195, 44, 1),
          centerTitle: true,
          title: const Text(
            'Check Parcel',
            style: TextStyle(
              fontFamily: 'roboto',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          leading: IconButton
          (
            icon: const Icon(
              Icons.arrow_back, 
              color: Colors.white, 
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/rider_home', (route) => false);
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
                                    // updateList(val);
                                    searchInput = val;
                                    filterParcel();
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Search Parcel...',
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
                ////////////////////
                ////////////////////
                ////////////////////
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
                                        title: const Text('Filter Category by'),
                                        insetPadding: EdgeInsets.zero,
                                        content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                title: const Text('My Parcel'),
                                                onTap: () async {
                                                  myParcel = true;
                                                  setState(() {
                                                    parcelCategory =
                                                        'My Parcel';
                                                    filterParcel();
                                                  });
                                                  // filterDeliveryStatus(
                                                  //     'all', myParcel);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                title: const Text('All'),
                                                onTap: () async {
                                                  setState(() {
                                                    parcelCategory = 'All';
                                                    filterParcel();
                                                  });
                                                  // filterDeliveryStatus(
                                                  //     'all', myParcel);
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
                            width: 130, // Adjust the width as needed
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
                                        Icons.supervisor_account,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                          width:
                                              5),
                                      Text(
                                        parcelCategory,
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
                      InkWell(
                        onTap: isLoading == true
                            ? null
                            : () async {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Filter status by'),
                                        insetPadding: EdgeInsets.zero,
                                        content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                title: const Text('All'),
                                                onTap: () async {
                                                  setState(() {
                                                    parcelStatus = 'All';
                                                  });
                                                  // filterDeliveryStatus(
                                                  //     'all', myParcel);
                                                  filterParcel();
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                title: const Text('Arrived'),
                                                onTap: () async {
                                                  parcelStatus = 'Arrived';
                                                  // filterDeliveryStatus(
                                                  //     'arrived', myParcel);
                                                  filterParcel();
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                title: const Text('Collected'),
                                                onTap: () async {
                                                  parcelStatus = 'Collected';
                                                  // filterDeliveryStatus(
                                                  //     'collected', myParcel);
                                                  filterParcel();
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                title: const Text('Delivered'),
                                                onTap: () async {
                                                  parcelStatus = 'Delivered';
                                                  // filterDeliveryStatus(
                                                  //     'delivered', myParcel);
                                                  filterParcel();
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                title: const Text('Waiting'),
                                                onTap: () async {
                                                  parcelStatus = 'Waiting';
                                                  // filterDeliveryStatus(
                                                  //     'waiting', myParcel);
                                                  filterParcel();
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
                            width: 130, // Adjust the width as needed
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
                                              5), // Adjust the spacing as needed
                                      Text(
                                        parcelStatus,
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
                /////////////////
                /////////////////
                /////////////////
                /////////////////
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
                      0: FlexColumnWidth(4),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD233),
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
                                  const Text(
                                    'Parcel Detail',
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
                                        parcel_counter++;
                                        parcel_counter = parcel_counter % 2;
                                        sortTrackingNumber();
                                        print(
                                            'Parcel Counter: ${parcel_counter}');
                                      });
                                    },
                                    child: parcel_counter == 0
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
                                      'Delivery Status',
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
                                        sortDeliveryStatus();
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
                  
                      if (parcel_list != null)
                        for (var rowData in parcel_list)
                          TableRow(
                            decoration: BoxDecoration(
                              color: parcel_list.indexOf(rowData) % 2 == 0
                                  ? const Color.fromARGB(255, 255, 245, 211)
                                  : null,
                            ),
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rowData['tracking_id'].toString(),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontFamily: 'Lexend',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    rowData['status'].toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontFamily: 'Lexend',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ],
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