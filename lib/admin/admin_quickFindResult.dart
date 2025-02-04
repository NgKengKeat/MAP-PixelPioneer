import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../controller.dart';

class AdminQuickFindResult extends StatefulWidget {
  const AdminQuickFindResult({super.key});

  @override
  State<AdminQuickFindResult> createState() => _AdminQuickFindResultState();
}

class _AdminQuickFindResultState extends State<AdminQuickFindResult> {
  bool? phoneValid;
  bool? nameValid;
  String? phone;
  bool isLoading = false;
  final TextEditingController _trackingNumber = TextEditingController();
  final TextEditingController _customerName = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  TextEditingController deliveryStatusController = TextEditingController();
  TextEditingController shelfNumber = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void initializevariables() async {
    _trackingNumber.text = tracking_id;
    _customerName.text = customerName;
    _phoneNumber.text = customerNumber;
    deliveryStatusController.text = status;
    shelfNumber.text = shelf_number;

    print('all variables initialized.');
  }

  Future<void> updateParcel() async {
    try {
      // Assuming 'tracking_id' is unique and directly accessible as a document ID
      await FirebaseFirestore.instance
          .collection('parcels')
          .doc(tracking_id) // Assuming 'tracking_id' is the document ID
          .update({'status': "collected"});

      print('Parcel collected!');
    } catch (error) {
      print('Error updating parcel: $error');
      print('Failed to update parcel. Please try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    initializevariables();
    ///Only for testing delete if this page is finalized
    getParcel();
    // _trackingNumber.text = tracking_id;
    print(_trackingNumber);
  }

  ///Only for testing delete if this page is finalized
  Future<void> getParcel() async {
    try {
      // await findParcel();
      setState(() {});
    } catch (error) {
      print('Error fetching parcel data: $error');
    }
  }

  @override
  void dispose() {
    super.dispose();
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
            'Quick Find Result',
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
              Navigator.of(context).pushReplacementNamed('/admin_quickFind');
            },
          ),
        ),
        body: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 50.0,
                  ),
                  Container(
                    width: 220,
                    height: 70,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
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
                                'Parcel Detail',
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
                            alignment: Alignment.topLeft,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      enabled: false,
                                      // readOnly: true,
                                      controller: _trackingNumber,
                                      // enabled: true,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      maxLines: 1,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .singleLineFormatter,
                                      ],
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color.fromARGB(255,
                                            249, 249, 249), // Background color
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            width: 1.50,
                                            color: Color(0xFFFFD233),
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      readOnly: true,
                                      enabled: false,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 15,
                                        fontFamily: 'Lexend',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      controller: _customerName,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      maxLines: 1,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .singleLineFormatter,
                                      ],
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color.fromARGB(255,
                                            249, 249, 249), // Background color
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            width: 1.50,
                                            color: Color(0xFFFFD233),
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
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
                                  readOnly: true,
                                  enabled: false,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 15,
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w400,
                                  ),
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

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

                          ///Delivery Status...............
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
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
                                                text: 'Delivery Status',
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
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20.0),
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
                                    readOnly: true,
                                    enabled: false,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 15,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    controller: deliveryStatusController,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    textAlignVertical: TextAlignVertical.center,
                                    maxLines: 1,
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .singleLineFormatter,
                                    ],
                                    decoration: InputDecoration(
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ///Shelf..............
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 60,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
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
                                                text: 'Shelf number',
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
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20.0),
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
                                    readOnly: true,
                                    enabled: false,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 15,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    controller: shelfNumber,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    textAlignVertical: TextAlignVertical.center,
                                    maxLines: 1,
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .singleLineFormatter,
                                    ],
                                    decoration: InputDecoration(
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(
                    height: 20.0,
                  ),
                  InkWell(
                    onTap: isLoading == true
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });
                            phone = formatPhone(_phoneNumber.text);
                            phoneValid = await phone_check(phone!);
                            nameValid = await name_check(_customerName.text);
                            if (_formKey.currentState!.validate()) {
                              await updateParcel();
                              await getParcelList();
                              //change snackbar design
                              Fluttertoast.showToast(
                                msg: "The parcel has been collected!",
                              );
                              Navigator.pushNamedAndRemoveUntil(context,
                                  '/admin_quickFind', (route) => false);
                            } else {
                              Fluttertoast.showToast(
                                msg: "The parcel is not found!",
                              );
                            }
                            setState(() {
                              isLoading = false;
                            });
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
                      // if loading show indicator(optional)
                      child: isLoading == true
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Collected',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
