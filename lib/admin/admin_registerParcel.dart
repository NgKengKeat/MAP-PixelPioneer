import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../controller.dart';
import '../main.dart';

class AdminRegisterParcel extends StatefulWidget {
  const AdminRegisterParcel({super.key});

  @override
  State<AdminRegisterParcel> createState() => _AdminRegisterParcelState();
}

class _AdminRegisterParcelState extends State<AdminRegisterParcel> {
  bool isLoading = false;
  bool? phoneValid;
  bool? parcelUnique;
  bool? userExist;
  String? phone;
  String? userSelected;
  TextEditingController _trackingNumber = TextEditingController();
  TextEditingController _customerName = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  TextEditingController shelfNumber = TextEditingController();
  var code;
  final _formKey = GlobalKey<FormState>();

  DateTime? current;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
Future<void> registerParcel() async {
  setState(() => isLoading = true);

  try {
    // Check if the user exists in Firestore
    var userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: _customerName.text)
        .limit(1)
        .get();

    if (userQuery.docs.isNotEmpty) {
      var userId = userQuery.docs.first.id;
      await FirebaseFirestore.instance.collection('parcels').add({
        'tracking_id': _trackingNumber.text.toUpperCase(),
        'user_id': userId,
        'name': _customerName.text.toUpperCase(),
        'phone': phone,
        'shelf_number': shelfNumber.text.toUpperCase(),
        'status':'',
        'created_at':FieldValue.serverTimestamp(),
      });

      Fluttertoast.showToast(msg: "The parcel has been added!");
      Navigator.pushNamedAndRemoveUntil(
          context, '/admin_manageParcel', (route) => false);
      } else {
        // User does not exist, show dialog to handle this case
        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: const Text('User does not exist'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        print('Cancel register');
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Proceed to register the parcel anyway
                        await FirebaseFirestore.instance.collection('parcels').add({
                          'tracking_id': _trackingNumber.text.toUpperCase(),
                          'name': _customerName.text.toUpperCase(),
                          'phone': phone,
                          'shelf_number': shelfNumber.text.toUpperCase(),
                        });

                        Fluttertoast.showToast(msg: "The parcel has been added anyway!");
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/admin_manageParcel', (route) => false);
                      },
                      child: const Text('Register Anyway'),
                    ),
                  ],
                ));
      }
    } catch (error) {
      print('Error updating parcel: $error');
      Fluttertoast.showToast(msg: "Error updating parcel: $error");
    } finally {
      setState(() => isLoading = false);
    }
  }

//   Future<bool> _validatePhoneNumber(String number) async {
//     // Implement phone number validation logic
//     return true;
//   }
  
//   Future<bool> _checkParcelUnique(String trackingId) async {
//     // Check if the tracking ID is unique in Firestore
//     final result = await FirebaseFirestore.instance
//         .collection('parcels')
//         .where('tracking_id', isEqualTo: trackingId)
//         .get();
//     return result.docs.isEmpty;
//   }

//   Future<bool> _checkUserExists(String name) async {
//     // Check if the user exists in Firestore
//     final result = await FirebaseFirestore.instance
//         .collection('users')
//         .where('name', isEqualTo: name)
//         .get();
//     return result.docs.isNotEmpty;
//   }
// }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(250, 195, 44, 1),
          centerTitle: true,
          title: const Text(
            'Register Parcel',
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
              Navigator.of(context).pushReplacementNamed('/admin_manageParcel');
            },
          ),
        ),
        body: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(children: [
                const SizedBox(
                  height: 50.0,
                ),
                Container(
                  width: 220, // Adjusted width
                  height: 70, // Adjusted height
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(25), // Increased border radius
                    color: Colors.transparent,
                  ),
                  child: Stack(
                    children: [
                      // Background container
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF0F0AF9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                25), // Increased border radius
                          ),
                        ),
                      ),
                      // Inner shadow container
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              25), // Increased border radius
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Register Parcel',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontFamily: 'Roboto',
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
                /////////////////
                ///////Dalam Kotak Kuning/////////
                Container(
                    width: 390,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
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
                    child: Column(
                      children: [
                        Align(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('/admin_scantrackID');
                            },
                            child: Container(
                              width: 180,
                              height: 53,
                              alignment: Alignment.center,
                              decoration: ShapeDecoration(
                                color: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                    width: 1.50,
                                    color: Colors.blue, // Border color
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
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                      width:
                                          8), // Adjust the spacing between the icon and text
                                  Text(
                                    'Scan Tracking ID',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        /////////////////
                        ////////////////
                        Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 100,
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          width: 4, color: Color(0xFF333333)),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Tracking Number',
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
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 20.0,
                                ),
                                Container(
                                  width: 230,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          width: 4, color: Color(0xFF333333)),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: TextFormField(
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 15,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please fill in';
                                      } else if (parcelUnique == false) {
                                        return 'Parcel Exist';
                                      } else {
                                        return null;
                                      }
                                    },
                                    controller: _trackingNumber,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    textAlignVertical: TextAlignVertical.center,
                                    maxLines: 1,
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .singleLineFormatter,
                                    ],
                                    decoration: InputDecoration(
                                      hintText: "enter tracking number",
                                      filled: true,
                                      fillColor: const Color.fromARGB(255, 249,
                                          249, 249), // Background color
                                      border: OutlineInputBorder(
                                        // Use OutlineInputBorder for rounded borders
                                        borderRadius: BorderRadius.circular(
                                            10), // This sets the rounded corners for the text field
                                        borderSide: const BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          width: 1.50,
                                          color: Color(0xFFFFD233),
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 10),
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                        /////////////////////////////////////////////////
                        /////Name........
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 100,
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          width: 4, color: Color(0xFF333333)),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Name',
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
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 20.0,
                                ),
                                TypeAheadField(
                                  suggestionsCallback: (value) {
                                    print('value : $value');
                                    if (value.isEmpty) {
                                      return List<String>.empty();
                                    }
                                    return list_name
                                        .where((element) => element
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                        .toList();
                                  },
                                  builder: (context, controller, focusNode) {
                                    return Container(
                                      width: 230,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                              width: 4,
                                              color: Color(0xFF333333)),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _customerName,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        focusNode: focusNode,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please fill in';
                                          } else {
                                            return null;
                                          }
                                        },
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontSize: 15,
                                          fontFamily: 'Lexend',
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                            hintText: 'enter name',
                                            filled: true,
                                            fillColor: const Color.fromARGB(
                                                255, 249, 249, 249),
                                            border: OutlineInputBorder(
                                              // Use OutlineInputBorder for rounded borders
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                width: 0,
                                                style: BorderStyle.none,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 10)),
                                        // autofocus: true,
                                      ),
                                    );
                                  },
                                  hideOnEmpty: true,
                                  constraints: const BoxConstraints(maxHeight: 500),
                                  itemBuilder: (context, String suggestion) {
                                    String selectPhone = "";
                                    for (var entry in list_user) {
                                      if (entry['name'] == suggestion) {
                                        selectPhone = entry['phone'];
                                      }
                                    }
                                    return ListTile(
                                      title: Text(suggestion),
                                      subtitle: Text(selectPhone),
                                    );
                                  },
                                  onSelected: (String suggestion) {
                                    setState(() {
                                      String selectPhone = "";
                                      for (var entry in list_user) {
                                        if (entry['name'] == suggestion) {
                                          selectPhone = entry['phone'];
                                        }
                                      }
                                      _customerName.text = suggestion;
                                      _phoneNumber.text = selectPhone;
                                    });
                                  },
                                  controller: _customerName,
                                ),
                              ]),
                        ),
                        const SizedBox(height: 10),
                        //////////////////////////////////////////////////////
                        ///Phone......
                        Align(
                          alignment: Alignment.topLeft,
                          child: Row(children: [
                            Container(
                              width: 100,
                              height: 60,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 4, color: Color(0xFF333333)),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Phone',
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
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 20.0,
                            ),
                            Container(
                              width: 230,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 4, color: Color(0xFF333333)),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: TextFormField(
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 15,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w400,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please fill in';
                                  } else if (phoneValid == false) {
                                    return 'Invalid Phone Number';
                                  } else {
                                    return null;
                                  }
                                },
                                controller: _phoneNumber,
                                textCapitalization:
                                    TextCapitalization.characters,
                                textAlignVertical: TextAlignVertical.center,
                                maxLines: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter,
                                ],
                                decoration: InputDecoration(
                                  hintText: "enter mobile numbers",
                                  filled: true,
                                  fillColor: const Color.fromARGB(
                                      255, 249, 249, 249), // Background color
                                  border: OutlineInputBorder(
                                    // Use OutlineInputBorder for rounded borders
                                    borderRadius: BorderRadius.circular(
                                        10), // This sets the rounded corners for the text field
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      width: 1.50,
                                      color: Color(0xFFFFD233),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 10),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 10),
                        //////////////////////////////////////////////////////
                        ///Phone......
                        Align(
                          alignment: Alignment.topLeft,
                          child: Row(children: [
                            Container(
                              width: 100,
                              height: 60,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 4, color: Color(0xFF333333)),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Shelf Number',
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
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 20.0,
                            ),
                            Container(
                              width: 230,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 4, color: Color(0xFF333333)),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: TextFormField(
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 15,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w400,
                                ),
                                // controller:,
                                textCapitalization:
                                    TextCapitalization.characters,
                                textAlignVertical: TextAlignVertical.center,
                                maxLines: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter,
                                ],
                                decoration: InputDecoration(
                                  hintText: "enter shelf number",
                                  filled: true,
                                  fillColor: const Color.fromARGB(
                                      255, 249, 249, 249), // Background color
                                  border: OutlineInputBorder(
                                    // Use OutlineInputBorder for rounded borders
                                    borderRadius: BorderRadius.circular(
                                        10), // This sets the rounded corners for the text field
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      width: 1.50,
                                      color: Color(0xFFFFD233),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 10),
                                ),
                                controller: shelfNumber,
                              ),
                            ),
                          ]),
                        ),
                      ],
                    )),

                /////////////////////////
                /////////////////////////
                const SizedBox(
                  height: 30.0,
                ),
                /////////////////////////
                /////////////////////////
                InkWell(
                  onTap: isLoading == true
                      ? null
                      : () async {
                          // Your code to handle the tap event
                          // setState(() {
                          //   isLoading = true;
                          // });
                          phone = await formatPhone(_phoneNumber.text);
                          phoneValid = await phone_check(phone!);
                          parcelUnique = await parcel_unique(
                              _trackingNumber.text.toUpperCase());
                          userExist = await user_exist(
                              _customerName.text.toUpperCase());
                          if (_formKey.currentState!.validate()) {
                            await registerParcel();
                            //change snackbar design
                            await getParcelList();
                          } else {
                            print('cannot register');
                          }
                          // setState(() {
                          //   isLoading = false;
                          // });
                        },
                  child: Container(
                    width: 180,
                    height: 53,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: const Color.fromARGB(255, 44, 174, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                          width: 1.50,
                          color: Color.fromARGB(
                              255, 44, 174, 48), // Border color
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
                        : const Text(
                            'Confirm',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 15,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
