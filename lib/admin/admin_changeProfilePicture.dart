import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import '../controller.dart';
import '../main.dart';

class AdminChangePicture extends StatefulWidget {
  const AdminChangePicture({super.key});

  @override
  State<AdminChangePicture> createState() => AdminChangePictureState();
}

class AdminChangePictureState extends State<AdminChangePicture> {
  dynamic image;
  XFile? fileImage;
  File? imageFile;
  bool isImageSelected = false;
  bool? passMatch;
  bool isLoading = false;
  TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

   final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Function to re-authenticate user and check if the password is correct
  Future<bool> reAuthenticateUser(String email, String password) async {
    try {
      // Attempt to re-authenticate
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user !=
          null; // Returns true if re-authentication is successful
    } on FirebaseAuthException catch (e) {
      print(e); // Handle errors or log them
      return false; // Return false if authentication fails
    }
  }

  Future<bool> checkPassword(String password) async {
    String userEmail = FirebaseAuth.instance.currentUser!.email!;
    bool isValid = await reAuthenticateUser(userEmail, password);
    if (isValid) {
      return true;
    } else {
      return false;
    }

  }
  Future<void> uploadImage() async {
    if (imageFile == null) {
      return;
    }
    try {
      setState(() => isLoading = true);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('admins')
          .child(user.uid)
          .child('${user.uid}.jpg');

      await ref.putFile(imageFile!);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'picture_url': url,
      });

      final adminRef = FirebaseFirestore.instance.collection('admin');
      await FirebaseFirestore.instance
          .collection('admin')
          .where('user_id', isEqualTo: user.uid)
          .get()
          .then((querySnapShot) {
            querySnapShot.docs.forEach((doc) {
            adminRef.doc(doc.id).update({'picture_url': url});
            });
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Picture Updated Successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void getImage() async {
    final XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
        isImageSelected = true;
      });
    }
    setState(() {
      fileImage = pickedImage;
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
            Navigator.pushNamedAndRemoveUntil(
                context, '/admin_profile', (route) => false);
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
                                  width: 100, // Adjust the width as needed
                                  height: 100, // Adjust the height as needed
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFFD233), // Border color
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
                const SizedBox(height: 30),
                const Text(
                  'Change Your Account\'s Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9B9B9B),
                    fontSize: 17,
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: isImageSelected == true
                                  ? Image(image: FileImage(imageFile!))
                                  : ((picture_url != null)
                                      ? admin_picture
                                      : Container(
                                          color: Colors.grey,
                                          child: const Center(
                                            child: Text('No image'),
                                          ),
                                        )),
                            ),
                            Container(
                              width: 150,
                              child: ElevatedButton(
                                onPressed: () async {
                                  getImage();
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blue),
                                ),
                                child: const Text('Upload Photo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                            ),
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
                                  hintText: "enter a password ",
                                  filled: true,
                                  fillColor:
                                      const Color.fromARGB(255, 249, 249, 249),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 10),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      width: 1.50,
                                      color: Color(0xFFFFD233),
                                    ),
                                  ),
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
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: isLoading == true
                                      ? null
                                      : () async {
                                          // Your code to handle the tap event
                                          print('clicked');
                                          setState(() {
                                            isLoading = true;
                                          });
                                          passMatch = await checkPassword(_passwordController.text);
                                          if (_formKey.currentState!
                                              .validate()) {
                                            print('process image');
                                            await uploadImage();
                                            await getAdminData(getID());
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Profile Picture Updated Successfully')));
                                            Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                '/admin_profile',
                                                (route) => false);
                                          }

                                          setState(() {
                                            print('finish');
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
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(
                                          width: 1.50,
                                          color: Color.fromARGB(
                                              255, 44, 174, 48),
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
      ]),
    );
  }
}
