import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../controller.dart';
import '../main.dart';

class AdminChangePhone extends StatefulWidget {
  const AdminChangePhone({super.key});

  @override
  State<AdminChangePhone> createState() => _AdminChangePhoneState();
}

class _AdminChangePhoneState extends State<AdminChangePhone> {
  bool isLoading = false;
  String? _phone;
  bool? passMatch;
  bool? phoneUnique;
  bool? phoneValid;
  dynamic image;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> phone_unique(String phone) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: _phone!)
          .limit(1)
          .get();

      // If we find any documents, the phone number is not unique
      if (querySnapshot.docs.isNotEmpty) {
        return false;
      }
      // If no documents were found, the phone number is unique
      return true;
    } catch (e) {
      print('Error checking phone uniqueness: $e');
      return false; // You might want to handle this differently based on your error handling policy
    }
  }

  Future<bool> checkPassword(String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return false;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      UserCredential result =
          await user.reauthenticateWithCredential(credential);
      return result.user != null;
    } catch (e) {
      print('Error re-authenticating user: $e');
      return false;
    }
  }

  Future<void> setPhone(String phone) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'phone': phone});

    final adminRef = FirebaseFirestore.instance.collection('admin');
    await FirebaseFirestore.instance
        .collection('admin')
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((querySnapShot) {
      querySnapShot.docs.forEach((doc) {
        adminRef.doc(doc.id).update({'phone': phone});
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
          'Update Profile',
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
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(children: [
        ListView(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 20.0,
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
                              color: Color.fromRGBO(250, 195, 44, 1),
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
                const SizedBox(height: 40.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //row to put the buttons
                    children: [
                      Padding(
                          //padding for all column
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                              //row to put image + name
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(
                                          0xFFFFD233), // Border color
                                      width: 1.0, // Border width
                                    ),
                                  ),
                                  child: ClipOval(
                                      child: picture_url != null
                                          ? admin_picture!
                                          : Container(
                                              color: Colors.grey,
                                            )),
                                ),
                                const SizedBox(width: 10.0),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        admin_name ?? 'Loading..',
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontSize: 22,
                                          fontFamily: 'Lexend',
                                          fontWeight: FontWeight.w700,
                                          height: 0,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.call,
                                            color: Color(0xFFFFD233),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            admin_phone ?? 'Loading..',
                                            style: const TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontSize: 15,
                                              fontFamily: 'Lexend',
                                              fontWeight: FontWeight.w100,
                                              height: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.email,
                                            color: Color(0xFFFFD233),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            admin_email ?? 'Loading..',
                                            style: const TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontSize: 15,
                                              fontFamily: 'Lexend',
                                              fontWeight: FontWeight.w100,
                                              height: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ])
                              ])),
                    ]),
                /////////////////////////////////////
                const SizedBox(height: 70),
                const Text(
                  'Change Your Phone Number ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9B9B9B),
                    fontSize: 17,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ////////////////////////////////////
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              width: 263,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  width: 0.5,
                                  color: const Color.fromARGB(56, 25, 25, 25),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(164, 117, 117, 117),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter phone number';
                                  } else if (phoneValid == false) {
                                    return 'Enter Valid Phone Number';
                                  } else if (phoneUnique == false) {
                                    return 'Phone Number Already Exist';
                                  } else {
                                    return null;
                                  }
                                },
                                controller: _phoneController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                textAlignVertical: TextAlignVertical.center,
                                maxLines: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter,
                                ],
                                decoration: InputDecoration(
                                  hintText: "enter new phone number",
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
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Color(0xFFFFD233),
                                  ),
                                ),
                              ),
                            ),
                            ///////////////////////
                            const SizedBox(height: 30),
                            const Text(
                              'Enter your password for confirmation',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF9B9B9B),
                                fontSize: 17,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                            const SizedBox(height: 20),

                            //////////////////////
                            Container(
                              width: 263,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  width: 0.5,
                                  color: const Color.fromARGB(56, 25, 25, 25),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(164, 117, 117, 117),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                textAlignVertical: TextAlignVertical.center,
                                maxLines: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter,
                                ],
                                decoration: InputDecoration(
                                  hintText: "enter password ",
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
                                  prefixIcon: const Icon(
                                    Icons.password,
                                    color: Color(0xFFFFD233),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  } else if (passMatch == false) {
                                    return 'Password does not match';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 70),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: isLoading == true
                                        ? null
                                        : () async {
                                            // Your code to handle the tap event
                                            setState(() {
                                              isLoading = true;
                                            });
                                            passMatch = await checkPassword(
                                                _passwordController.text);
                                            _phone = formatPhone(
                                                _phoneController.text);
                                            phoneValid = phone_check(_phone!);
                                            phoneUnique =
                                                await phone_unique(_phone!);
                                            if (_formKey.currentState!
                                                .validate()) {
                                              await setPhone(_phone!);
                                              await getAdminData(getID());
                                              //change snackbar design
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Phone Number Updated Successfully')));
                                              Navigator.pushNamedAndRemoveUntil(
                                                  context,
                                                  '/admin_profile',
                                                  (route) => false);
                                            }
                                            setState(() {
                                              isLoading = false;
                                            });
                                          },
                                    child: Container(
                                      width: 263,
                                      height: 53,
                                      alignment: Alignment.center,
                                      decoration: ShapeDecoration(
                                        color: const Color.fromARGB(
                                            255, 44, 174, 48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          side: const BorderSide(
                                            width: 1.50,
                                            color: Color.fromARGB(255, 44, 174,
                                                48), // Border color
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
                                              'confirm',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontSize: 15,
                                                fontFamily: 'Lexend',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                    ),
                                  ),
                                ])
                          ],
                        ),
                      ),
                    ],
                    // ],
                  ),
                ),

                ///end
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
      ]),
    );
  }
}
