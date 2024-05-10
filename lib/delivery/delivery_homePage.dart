import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import '../controller.dart';
import '../main.dart';

class DeliveryHomePage extends StatefulWidget {
  const DeliveryHomePage({super.key});

  @override
  State<DeliveryHomePage> createState() => _DeliveryHomePageState();
}

class _DeliveryHomePageState extends State<DeliveryHomePage> {
  int? checkedIndex;
  bool? deliveryExist;
  bool isLoading = false;
  bool enableButton = false;
  void riderModeDeactivate() async {
    setState(() {
      riderMode = false;
    });
    await updateRiderStatus(user_rider[0]['rider_id'], 'offline');
    await getRiderStatus();
    Navigator.pushNamedAndRemoveUntil(context, '/rider_home', (route) => false);
  }

  void setButtonColor(bool x) async {
    await checkDelivery();
    // print(isDeliver);
    setState(() {
      isDeliver;
    });
    // print(isDeliver);

    if (isDeliver == true) {
      setState(() {
        deliveryExist = true;
        enableButton = false;
      });
    } else {
      setState(() {
        enableButton = x;
      });
    }
  }

  Future<void> _showConfirmationDialog(bool newValue) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Switch OFF to Rider Mode?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog without updating the riderMode value
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog and update the riderMode value
                Navigator.of(context).pop();
                riderModeDeactivate();
              },
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

   Future<void> setRiderBooking() async {
    if (checkedIndex == null) {
      print('no check');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('booking')
          .doc(requested_parcel[checkedIndex]['booking_id'])
          .update({
            'rider_id': rider['rider_id'],
            'booking_status': 'accepted'
          });
    } catch (e) {
      print(e.toString());
    }
  }

Future<bool> validateRiderDelivery() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('booking')
        .where('rider_id', isEqualTo: rider['rider_id'])
        .where('booking_status', isEqualTo: 'accepted')
        .get();

    return snapshot.docs.isNotEmpty;
  }


  updateData() async {
    await getRequestedParcelList();
    if (mounted) {
      setState(() {
        requested_parcel;
      });
    }
  }

  @override
  void initState() {
    super.initState();

     // Subscribe to changes
    FirebaseFirestore.instance
        .collection('booking_parcel')
        .where('parcel', arrayContainsAny: requested_parcel.map((e) => e['parcel_id']).toList())
        .snapshots()
        .listen((snapshot) {
          print('Change received: ${snapshot.docs}');
          updateData();
        });
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
            'Rider Homepage',
            style: TextStyle(
              fontFamily: 'roboto',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Rider Mode :',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                ),
                              ),
                              // SizedBox(height: 20),
                              Switch(
                                value: riderMode,
                                onChanged: (value) async {
                                  // Show the confirmation dialog before changing the riderMode value
                                  await _showConfirmationDialog(value);
                                },
                                activeTrackColor: Colors.lightGreenAccent,
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // crossAxisAlignment: CrossAxisAlignment.,
                            children: [
                              Text(
                                'CPP',
                                style: TextStyle(
                                  color: Color.fromRGBO(248, 134, 41, 1),
                                  fontSize: 48,
                                  fontFamily: 'Montagu Slab',
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(
                                      color: Color.fromARGB(255, 145, 145, 145),
                                      offset: Offset(0, 3),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Link',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 7, 7, 131),
                                  fontSize: 32,
                                  fontFamily: 'Montagu Slab',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Customer Delivery Request:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 17,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 10, left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              height: 300,
                              padding: const EdgeInsets.all(16),
                              color: const Color.fromARGB(255, 174, 174, 174),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: requested_parcel == null
                                          ? 0
                                          : requested_parcel.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10, left: 10),
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(bottom: 10.0),
                                            decoration: BoxDecoration(
                                              color: const Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          ////
                                                          const Text(
                                                            'Parcel ID : ',
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF333333),
                                                              fontSize: 17,
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              height: 0.00,
                                                            ),
                                                          ),
                                                          Text(
                                                            requested_parcel[
                                                                        index][
                                                                    'booking_parcel']
                                                                .map((e) => e[
                                                                        'parcel']
                                                                    [
                                                                    'tracking_id'])
                                                                .join(',\n'),
                                                            style: const TextStyle(
                                                              color: Color(
                                                                  0xFF333333),
                                                              fontSize: 17,
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              height: 0.00,
                                                            ),
                                                          ),
                                                          /////
                                                          Row(
                                                            children: [
                                                              const Text(
                                                                'Address : ',
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xFF333333),
                                                                  fontSize: 17,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 0.00,
                                                                ),
                                                              ),
                                                              requested_parcel[
                                                                              index]
                                                                          [
                                                                          'address'] ==
                                                                      null
                                                                  ? const Text(
                                                                      'No address',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xFF333333),
                                                                        fontSize:
                                                                            17,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        height:
                                                                            0.00,
                                                                      ),
                                                                    )
                                                                  : Text(
                                                                      requested_parcel[
                                                                              index]
                                                                          [
                                                                          'address'],
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Color(
                                                                            0xFF333333),
                                                                        fontSize:
                                                                            17,
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        height:
                                                                            0.00,
                                                                      ),
                                                                    ),
                                                            ],
                                                          ),
                                                        ]),
                                                  ),
                                                  Container(
                                                    child: Row(
                                                      children: [
                                                        Transform.scale(
                                                          scale: 1.3,
                                                          child: Checkbox(
                                                            value:
                                                                checkedIndex ==
                                                                    index,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                if (value ==
                                                                    true) {
                                                                  checkedIndex =
                                                                      index;
                                                                  setButtonColor(
                                                                      true);
                                                                } else {
                                                                  checkedIndex =
                                                                      null;
                                                                  setButtonColor(
                                                                      false);
                                                                }
                                                              });
                                                            },
                                                            activeColor:
                                                                Colors.green,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
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
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        deliveryExist = await validateRiderDelivery();
                        if (checkedIndex == null && deliveryExist == false) {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('I understand'))
                                    ],
                                    title: const Text('Please Select (1) Parcel'),
                                  ));
                        } else if (deliveryExist == true) {
                          print('delivery exist');
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('I understand'))
                                    ],
                                    title:
                                        const Text('You can only deliver one parcel'),
                                  ));
                        } else {
                          await updateRiderStatus(user_rider[0]['rider_id'], "delivering");
                          await getRequestedParcelList();
                          await setRiderBooking();
                          await getRequestedParcelList();
                          await getRiderParcel(rider['rider_id']);
                          setButtonColor(false);
                          setState(() {});
                          print('Rider set');
                          Fluttertoast.showToast(
                            msg: "Parcel ready to be delivered!",
                          );
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Container(
                          width: 294,
                          // height: 36,
                          decoration: ShapeDecoration(
                            color: enableButton
                                ? const Color.fromRGBO(248, 134, 41, 1)
                                : Colors.grey,
                            // containerColor
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Deliver Now',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: 'Lexend',
                                            fontWeight: FontWeight.w400,
                                            height: 0.00,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Add your delete parcel logic here
                        Navigator.pushReplacementNamed(
                            context, '/delivery_list');
                        // You can replace the print statement with the actual logic to delete the parcel.
                      },
                      child: Container(
                          width: 294,
                          // height: 36,
                          decoration: ShapeDecoration(
                            color: const Color.fromRGBO(248, 134, 41, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Delivery History',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: 'Lexend',
                                            fontWeight: FontWeight.w400,
                                            height: 0.00,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),

                    ///end
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Add your delete parcel logic here

                        Navigator.pushReplacementNamed(context,
                            '/delivery_profilePage'); // You can replace the print statement with the actual logic to delete the parcel.
                      },
                      child: Container(
                          width: 294,
                          // height: 36,
                          decoration: ShapeDecoration(
                            color: const Color.fromRGBO(248, 134, 41, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'View Profile',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: 'Lexend',
                                            fontWeight: FontWeight.w400,
                                            height: 0.00,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
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
      ),
    );
  }
}
