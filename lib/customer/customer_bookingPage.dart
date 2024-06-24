import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pixelpioneer_cpplink/controller.dart';
import 'package:pixelpioneer_cpplink/customer/customer_college.dart';
import 'package:pixelpioneer_cpplink/customer/customer_riderPage.dart';

// ignore: camel_case_types
class customerBooking extends StatefulWidget 
{
  const customerBooking({super.key});

  @override
  State<customerBooking> createState() => customerBookingState();
}

// ignore: camel_case_types
class customerBookingState extends State<customerBooking> 
{
  String colleage = '';
  String block = '';

  // TextEditingController _address = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool newBooking = true;
  List<String> selectedValues = [];
  bool parcel = false;
  // ignore: prefer_typing_uninitialized_variables
  var price;
  bool delivered = false;
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  List<String> parcelTrackingIds = [];
  String? selectedTrackingId;


  setChargePrice(String colleage) 
  {
    price = 1;
    
      switch (colleage) {
        case 'KTDI':
          price = price + 2;
          break;
        case 'KTHO':
          price = price + 2;

          break;
        case 'KTR':
          price = price + 2;

          break;
        case 'KDSE':
          price = price + 2;

          break;
        case 'KDOJ':
          price = price + 3;

          break;
        case 'KTC':
          price = price + 3;

          break;
        case 'K9&K10':
          price = price + 3;

          break;
      }
   
    if (kDebugMode) {
     // print("TOTAL PRICE : " + price.toString());
    }
  }


  Future<void> fetchUserData() async 
  {
  if (userId != null) {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users') 
          .doc(userId)
          .get();


      if (userData.exists && userData.data() != null) {
        setState(() {
         user_name = userData.get('name') ?? "unknown";
        });
      } else {
        setState(() {
         user_name= "unknown"; 
        });
      }
    } catch (error) {
      // print("Error fetching user data: $error");
      setState(() {
         user_name = "unknown"; 
      });
    }
  }
}


 Future<void> fetchTrackingIds(String id, String phone) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('parcels')
          .where('user_id', isEqualTo: id)
          .where('status', whereIn: ['waiting', 'cancelled'])
          .where('phone', isEqualTo: phone)
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
      // print('Error fetching tracking IDs: $e');
    }
  }


 Future<void> fetchUserPhoneNumber() async {
  if (userId != null) {
    try {

      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users') 
          .doc(userId)
          .get();

      if (userData.exists && userData.data() != null) {
        setState(() {
       
          user_phone = userData.get('phone') ?? "unknownPhoneNumber";
        });
      } else {
        setState(() {
          user_phone = "Guest"; 
        });
      }
    } catch (error) {
      // print("Error fetching user data: $error");
      setState(() {
        user_phone = "Guest"; 
      });
    }
  }
}

Future<void> addBookingParcel(String name, String phone, String address, String trackingid,int price) async {
  try 
  {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('booking')
        .where('name', isEqualTo: name)
        .where('phone', isEqualTo: phone)
        .where('address', isEqualTo: address)
        .where('tracking_id', isEqualTo: trackingid)
        .where('charged_price', isEqualTo: price)
        .get();

    if (querySnapshot.docs.isEmpty) 
    {
      await FirebaseFirestore.instance.collection('booking').add({
        'name': name,
        'phone': phone,
        'address': address,
        'tracking_id': trackingid,
        'charged_price':price,
        'rider_id':"",
        'timestamp': Timestamp.now(),
        'customer_id':userId,
        'booking_status':'request'
      });
      // print('Successfully added to booking collection');
    } else {
      // print('Booking entry already exists');
    }
  } catch (error) {
    // print('Error adding to booking collection: $error');
  }
}

  Future<bool> checkSelectedValues() async {
    bool exist = false;
    for (String s in selectedValues) {
      if (s.isEmpty) {
        exist = false;
        break;
      }
      exist = true;
    }
    return exist;
  }

  void resetBlock() {
    setState(() {
      block = '';
    });
  }

  
  void updateBlock(String _block) {
    setState(() {
      block = _block;
    });
  }



  Future<void> updateListParcel() async {
  // await getArrivedParcel(FirebaseAuth.instance.currentUser!.uid);
    if (mounted) {
      setState(() {
        // Update user_parcel state
        user_parcel;
      });
      // Example navigation logic based on delivered status
      if (delivered) {
        Navigator.of(context).pushReplacementNamed('/customer_home');
      }
    }
  }

  

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedValue = null;
      fetchUserData();
      fetchUserPhoneNumber();
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchTrackingIds(userId!,user_phone);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 195, 44, 1),
        centerTitle: true,
        title: const Text(
          'Booking Delivery',
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
      body: Stack(
        children: [
          ListView(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container
                  (
                    width: 390, 
                    height: 70,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(25), 
                      color: Colors.transparent,
                    ),
                    child: Stack(
                      children: [
                      
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                25), // Increased border radius
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Book Delivery',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 38,
                                  fontFamily: 'Montagu Slab',
                                  fontWeight: FontWeight.w400,
                                  height: 0.00,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox
                  (
                    height: 10.0,
                  ),
                  /////////////////
                  ///////Dalam Kotak Kuning/////////
                  Container(
                    width: 390,
                    height: 450,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFFD233),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(6, 5),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    ////////////////////////////////////////////////
                    ///Tracking Number.......
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align children to the left
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align children to the left
                              children: [
                                const Row(
                                  children: [
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '   Name',
                                              style: TextStyle(
                                                color: Color(0xFF050505),
                                                fontSize: 20,
                                                fontFamily: 'Lexend',
                                                fontWeight: FontWeight.w400,
                                                height: 0.00,
                                              ),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Container(
                                  width: 350,
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 7),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          width: 2, color: Color(0xFF333333)),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    user_name,
                                    style: const TextStyle(
                                      fontSize: 20,
                             
                                    ),
                                  ),
                                )
                                
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          /////////////////////////////////////////////////////////
                          ///////Phone Number ......
                          Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align children to the left
                              children: [
                                const Row(
                                  children: [
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '   Phone Number',
                                              style: TextStyle(
                                                color: Color(0xFF050505),
                                                fontSize: 20,
                                                fontFamily: 'Lexend',
                                                fontWeight: FontWeight.w400,
                                                height: 0.00,
                                              ),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Container
                                (
                                  width: 350,
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 7),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          width: 2, color: Color(0xFF333333)),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    user_phone,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          /////////////////////////////////////////////////////////
                          ///////Tracking Number ......
                            Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start,
                              children: [
                                const Row(
                                  children: [
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '   Tracking Number',
                                              style: TextStyle(
                                                color: Color(0xFF050505),
                                                fontSize: 20,
                                                fontFamily: 'Lexend',
                                                fontWeight: FontWeight.w400,
                                                height: 0.00,
                                              ),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Container(
                                    width: 350,
                                    height: 40,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            width: 2, color: Color(0xFF333333)),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                       
                                 child:
                          DropdownButton<String>(
  value: selectedTrackingId,
  hint: const Padding(
    padding: EdgeInsets.symmetric(horizontal: 18.0),
    child: Align(
      alignment: Alignment.centerLeft, 
      child: Text(
        'Select your parcel',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
    ),
  ),
  onChanged: (String? newValue) {
    setState(() {
      selectedTrackingId = newValue!;
      parcel = newValue.isNotEmpty;
    });
  },
  items: parcelTrackingIds.map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(value),
        ),
      ),
    );
  }).toList(),
),

                                
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          /////////////////////////////////////////////////////////
                          ///////Address ......
                          const Row(
                            children: [
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '   Address',
                                        style: TextStyle(
                                          color: Color(0xFF050505),
                                          fontSize: 20,
                                          fontFamily: 'Lexend',
                                          fontWeight: FontWeight.w400,
                                          height: 0.00,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Container(
                            width: 350,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 2, color: Color(0xFF333333)),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
////////////////////////////////
///////////////////////////////
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text('Colleage : ',
                                                  style: TextStyle(
                                                    color: Color(0xFF050505),
                                                    fontSize: 20,
                                                    fontFamily: 'Lexend',
                                                    fontWeight: FontWeight.w400,
                                                    height: 0.00,
                                                  )),
                                              InkWell(
                                                onTap: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'select your Colleage :'),
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                ListTile(
                                                                  title: const Text(
                                                                      'KTDI'),
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      colleage =
                                                                          'KTDI';
                                                                      resetBlock();
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                                ListTile(
                                                                  title: const Text(
                                                                      'KTHO'),
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      colleage =
                                                                          'KTHO';
                                                                      resetBlock();
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                                ListTile(
                                                                  title: const Text(
                                                                      'KTR'),
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      colleage =
                                                                          'KTR';

                                                                      resetBlock();
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                                ListTile(
                                                                  title: const Text(
                                                                      'KDSE'),
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      colleage =
                                                                          'KDSE';
                                                                      resetBlock();
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                                ListTile(
                                                                  title: const Text(
                                                                      'KDOJ'),
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      colleage =
                                                                          'KDOJ';
                                                                      resetBlock();
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                                ListTile(
                                                                  title: const Text(
                                                                      'KTC'),
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      colleage =
                                                                          'KTC';
                                                                      resetBlock();
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                                ListTile(
                                                                  title: const Text(
                                                                      'K9&K10'),
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      colleage =
                                                                          'K9&K10';
                                                                      resetBlock();
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                              ]),
                                                        );
                                                      });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    right: 8.0,
                                                  ),
                                                  child: Container(
                                                    width:
                                                        100, 
                                                    height: 40,
                                                    alignment: Alignment.center,
                                                    decoration: ShapeDecoration(
                                                      color: Colors.blue,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        side: const BorderSide(
                                                          width: 1.50,
                                                          color: Colors
                                                              .blue, // Border color
                                                        ),
                                                      ),
                                                      shadows: const [
                                                        BoxShadow(
                                                          color:
                                                              Color(0x3F000000),
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                          spreadRadius: 0,
                                                        ),
                                                      ],
                                                    ),
                                                    // if loading show indicator(optional)
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.apartment,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                            width:
                                                                5), 
                                                        Text(
                                                          colleage,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
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
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]),
                                        //////////////////////
                                        const SizedBox(height: 10),
                                        //////////////////////
                                        ///////////////
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text('Block Number: ',
                                                  style: TextStyle(
                                                    color: Color(0xFF050505),
                                                    fontSize: 20,
                                                    fontFamily: 'Lexend',
                                                    fontWeight: FontWeight.w400,
                                                    height: 0.00,
                                                  )),
                                                InkWell(
                                                onTap: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'select your Block Number:'),
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <Widget>[
                                                                buildListTileForColleague(
                                                                    colleage,
                                                                    updateBlock,
                                                                    context),
                                                              ]),
                                                        );
                                                      });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Container(
                                                    width:
                                                        100, 
                                                    height: 40,
                                                    alignment: Alignment.center,
                                                    decoration: ShapeDecoration(
                                                      color: Colors.blue,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        side: const BorderSide(
                                                          width: 1.50,
                                                          color: Colors
                                                              .blue, // Border color
                                                        ),
                                                      ),
                                                      shadows: const [
                                                        BoxShadow(
                                                          color:
                                                              Color(0x3F000000),
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                          spreadRadius: 0,
                                                        ),
                                                      ],
                                                    ),
                                                    // if loading show indicator(optional)
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.home,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                            width:
                                                                5), 
                                                        Text(
                                                          block,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
                                                            color: Color
                                                                .fromARGB(255,
                                                                255, 255, 255),
                                                            fontSize: 17,
                                                            fontFamily:
                                                                'Lexend',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]),
////////////////////////////////
///////////////////////////////
                                      ]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ///////////////////////////////////////
                  /////////////////////////////////////
                  const SizedBox(
                    height: 30.0,
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });

                    
                      setChargePrice(colleage);

                      if (_formKey.currentState!.validate() &&
                          colleage.isNotEmpty &&
                          block.isNotEmpty &&
                          parcel == true) {
                        await addBookingParcel(user_name,user_phone,'$colleage,$block',selectedTrackingId!,price);
                        isLoading = false;
Navigator.push(
  // ignore: use_build_context_synchronously
  context,
  MaterialPageRoute(
    builder: (context) => customerRiderPage(
      name: user_name,
      trackingNumber: selectedTrackingId!,
      address: '$colleage, $block',
      price:price
    ),
  ),
);

                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                    
                            return AlertDialog(
                              title: const Text('Incomplete form'),
                              content: const Text(
                                  'Please fill the parcel tracking number, colleage and block!'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Ok',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
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
                          color: const Color.fromARGB(255, 0, 207, 62),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
                                        text: 'BOOK N0W',
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
                  const SizedBox(
                    height: 30.0,
                  ),
                ],
              )
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


