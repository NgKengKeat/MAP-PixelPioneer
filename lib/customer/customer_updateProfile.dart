import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixelpioneer_cpplink/controller.dart';

class CustomerProfile extends StatefulWidget {
  const CustomerProfile({Key? key}) : super(key: key);

  @override
  State<CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      }
    }
  }

  Future<void> deleteUser() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    // Delete the user's data from Firestore first
    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

    // Then delete the user's authentication record
    await user.delete();

    // If the deletion is successful, navigate the user to the login page
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account deleted successfully')),
    );
  } catch (e) {
    // Handle exceptions by showing a message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete account: $e')),
    );
  }
}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 195, 44, 1),
        centerTitle: true,
        title: const Text(
          'Account information',
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
            Navigator.of(context).pushReplacementNamed('/customer_home');
          },
        ),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                                    color: const Color(0xFFFFD233), // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                child: ClipOval(
                                    child: user_picture != null
                                        ? picture!
                                        : Container(
                                            color: Colors.grey,
                                          )),
                              ),
                              const SizedBox(width: 10.0),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user_name ?? 'Loading..',
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
                                          user_phone ?? 'Loading..',
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
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
                                          user_email ?? 'Loading..',
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            fontSize: 12,
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
              const SizedBox(height: 50),
              //Button
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      InkWell(
                        onTap: () {
                          // Your code to handle the tap event
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/changePFP', (route) => false);
                        },
                        child: Container(
                          width: 246,
                          height: 53,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFFD233),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                width: 1.50,
                                color: Color(0xFFFFD233), // Border color
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
                            'Change Profile Picture',
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
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          // Your code to handle the tap event
                          Navigator.pushNamed(context, '/changeName');
                        },
                        child: Container(
                          width: 246,
                          height: 53,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFFD233),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                width: 1.50,
                                color: Color(0xFFFFD233), // Border color
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
                            'Change Name',
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
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          // Your code to handle the tap event
                          Navigator.of(context).pushNamed('/changePw');
                        },
                        child: Container(
                          width: 246,
                          height: 53,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFFD233),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                width: 1.50,
                                color: Color(0xFFFFD233), // Border color
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
                            'Change Password',
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
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          // Your code to handle the tap event
                          Navigator.of(context).pushNamed('/changePhone');
                        },
                        child: Container(
                          width: 246,
                          height: 53,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFFD233),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                width: 1.50,
                                color: Color(0xFFFFD233), // Border color
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
                            'Change Phone Number',
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
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          // Your code to handle the tap event
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    content: const Text('Confirm Delete?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('No',
                                              style: TextStyle(
                                                  color: Colors.red))),
                                      TextButton(
                                        onPressed: () async {
                                           await deleteUser();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Account Deleted Successfully')));
                                          Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              '/login',
                                              (route) => false);
                                        },
                                        child: const Text('Yes',
                                            style:
                                                TextStyle(color: Colors.green)),
                                      ),
                                    ],
                                  ));
                        },
                        child: Container(
                          width: 246,
                          height: 53,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFFD233),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                width: 1.50,
                                color: Color(0xFFFFD233), // Border color
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
                            'Delete Account',
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

                    ///////////////////////////
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
