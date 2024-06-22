// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../controller.dart';
import '../main.dart';

class AdminChangePassword extends StatefulWidget {
  const AdminChangePassword({super.key});

  @override
  State<AdminChangePassword> createState() => _AdminChangePasswordState();
}

class _AdminChangePasswordState extends State<AdminChangePassword> {
  bool isLoading = false;
  bool? passMatch;
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> checkPassword() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return false;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPasswordController.text,
      );
      UserCredential result =
          await user.reauthenticateWithCredential(credential);
      return result.user !=
          null; // Returns true if re-authentication is successful
    } catch (e) {
      print('Error re-authenticating user: $e');
      return false;
    }
  }

  Future<bool> setPassword() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      print('User: $user');
      var userId = FirebaseAuth.instance.currentUser!.uid;
      print('userId: $userId');
      if (user == null) return false;

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'password': _newPasswordController.text.trim()});

        final adminRef = FirebaseFirestore.instance.collection('admin');
        await FirebaseFirestore.instance
            .collection('admin')
            .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((querySnapShot) {
          querySnapShot.docs.forEach((doc) {
            adminRef
                .doc(doc.id)
                .update({'password': _newPasswordController.text.trim()});
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully.')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update Password: $e')));
      }
      await user.updatePassword(_newPasswordController.text);
      return true; // Returns true if the password update is successful
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(250, 195, 44, 1),
        centerTitle: true,
        title: Text(
          'Update Profile',
          style: TextStyle(
            fontFamily: 'roboto',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
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
                SizedBox(
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
                SizedBox(height: 40.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //row to put the buttons
                    children: [
                      Padding(
                          //padding for all column
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                              //row to put image + name
                              children: [
                                Container(
                                  width: 100, // Adjust the width as needed
                                  height: 100, // Adjust the height as needed
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFFFFD233), // Border color
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
                                SizedBox(width: 10.0),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        admin_name ?? 'Loading..',
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontSize: 22,
                                          fontFamily: 'Lexend',
                                          fontWeight: FontWeight.w700,
                                          height: 0,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.call,
                                            color: Color(0xFFFFD233),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            admin_phone ?? 'Loading..',
                                            style: TextStyle(
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
                                          Icon(
                                            Icons.email,
                                            color: Color(0xFFFFD233),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            admin_email ?? 'Loading..',
                                            style: TextStyle(
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
                SizedBox(height: 70),
                Text(
                  'Change Your Account\'s Password ?',
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
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              width: 263,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  width: 0.5,
                                  color: Color.fromARGB(56, 25, 25, 25),
                                ),
                                boxShadow: [
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
                                    return 'Please enter new password';
                                  } else {
                                    return null;
                                  }
                                },
                                controller: _newPasswordController,
                                obscureText: true,
                                textAlignVertical: TextAlignVertical.center,
                                maxLines: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter,
                                ],
                                decoration: InputDecoration(
                                  hintText: "enter new password",
                                  filled: true,
                                  fillColor: const Color.fromARGB(
                                      255, 249, 249, 249), // Background color
                                  border: OutlineInputBorder(
                                    // Use OutlineInputBorder for rounded borders
                                    borderRadius: BorderRadius.circular(
                                        10), // This sets the rounded corners for the text field
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      width: 1.50,
                                      color: Color(0xFFFFD233),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 10),
                                  prefixIcon: Icon(
                                    Icons.password,
                                    color: Color(0xFFFFD233),
                                  ),
                                ),
                              ),
                            ),
                            ///////////////////////
                            SizedBox(height: 30),
                            Text(
                              'Enter your old password for confirmation',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF9B9B9B),
                                fontSize: 17,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                            SizedBox(height: 20),

                            //////////////////////
                            Container(
                              width: 263,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  width: 0.5,
                                  color: Color.fromARGB(56, 25, 25, 25),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(164, 117, 117, 117),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _oldPasswordController,
                                obscureText: true,
                                textAlignVertical: TextAlignVertical.center,
                                maxLines: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter,
                                ],
                                decoration: InputDecoration(
                                  hintText: "enter old password ",
                                  filled: true,
                                  fillColor: const Color.fromARGB(
                                      255, 249, 249, 249), // Background color
                                  border: OutlineInputBorder(
                                    // Use OutlineInputBorder for rounded borders
                                    borderRadius: BorderRadius.circular(
                                        10), // This sets the rounded corners for the text field
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      width: 1.50,
                                      color: Color(0xFFFFD233),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 10),
                                  prefixIcon: Icon(
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
                            SizedBox(height: 70),
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
                                            passMatch = await checkPassword();
                                            if (_formKey.currentState!
                                                .validate()) {
                                              await setPassword();
                                              await getAdminData(getID());
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Password Updated Successfully')));
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
                                          side: BorderSide(
                                            width: 1.50,
                                            color: const Color.fromARGB(255, 44,
                                                174, 48), // Border color
                                          ),
                                        ),
                                        shadows: [
                                          BoxShadow(
                                            color: Color(0x3F000000),
                                            blurRadius: 4,
                                            offset: Offset(0, 4),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'confirm',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color.fromARGB(
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
                        //////////////////////////////

                        ///////////////////////////
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
            color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
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
