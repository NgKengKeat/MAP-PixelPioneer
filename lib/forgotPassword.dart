import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:pixelpioneer_cpplink/controller.dart';
import 'main.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _emailController = TextEditingController();
  bool? emailUnique;
  bool isLoading = false;


  Future<void> resetPassword() async {
    setState(() {
      isLoading = true;
    });
    final email = _emailController.text.trim();
    
    // Check if the email exists in Firestore under 'users' collection
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userDoc.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user found with that email")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Send reset email
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent!")),
      );
      setEmail(email);
       Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print('Error sending reset email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send password reset email")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
            'Forgot Password',
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
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ),
        ////////////////////////////
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
                  // SizedBox(height: 20.0),
                  /////////////////////////////////////
                  /////////////////////////////////////
                  // SizedBox(height: 50),
                  // Text(
                  //   'RESET YOUR PASSWORD',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     // color: Color(0xFF9B9B9B),
                  //     color: Colors.black,

                  //     fontSize: 17,
                  //     fontFamily: 'Lexend',
                  //     fontWeight: FontWeight.w700,
                  //   ),
                  // ),
                  ////////////////////////////////////
                  const SizedBox(height: 40),

                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            const Text(
                              'Enter your email to reset password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                            const SizedBox(height: 20),

//////////////////////
                            Column(
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
                                        color:
                                            Color.fromARGB(164, 117, 117, 117),
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: _emailController,
                                    textAlignVertical: TextAlignVertical.center,
                                    maxLines: 1,
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .singleLineFormatter,
                                    ],
                                    decoration: InputDecoration(
                                      hintText: "enter email",
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
                                      prefixIcon: const Icon(
                                        Icons.email,
                                        color: Color(0xFFFFD233),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter an email';
                                      } else if (emailUnique == false) {
                                        return 'Email Already Exist';
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 70),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
//////////////////
                                  InkWell(
                                    onTap: () {
                                      resetPassword();
                                      // Your code to handle the tap event
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
                                            color: Color.fromARGB(255, 44,
                                                174, 48), // Border color
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
                                      child: const Text(
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
//////////////////////////////

                        ///////////////////////////
                      ),
                    ],
                    // ],
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
      ),
    );
  }
}
