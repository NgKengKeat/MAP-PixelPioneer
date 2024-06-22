import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controller.dart';
import '../main.dart';

class RiderChangeVehicle extends StatefulWidget {
  const RiderChangeVehicle({super.key});

  @override
  State<RiderChangeVehicle> createState() => _RiderChangeVehicleState();
}

class _RiderChangeVehicleState extends State<RiderChangeVehicle> {
  dynamic image;
  XFile? fileImage;
  File? imageFile;
  bool isImageSelected = false;
  bool? passMatch;
  bool isLoading = false;
  String _selectedVehicleType = 'Motorcycle';
  final user = FirebaseAuth.instance.currentUser;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _plateController = TextEditingController();
  TextEditingController _modelController = TextEditingController();
  TextEditingController _typeController = TextEditingController();
  TextEditingController _colourController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    displayImage();
    assignData();
  }

  @override
  void dispose() {
    super.dispose();
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

 Future<void> displayImage() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final riderRef = FirebaseFirestore.instance.collection('riders');
  
  final docSnapshot = await riderRef
      .where('userId', isEqualTo: userId)
      .get();
  
  if (docSnapshot.docs.isEmpty) {
    return;
  }

  final data = docSnapshot.docs.first.data();
  if (data['picture_url'] == null) {
    return;
  }

  if (mounted) {
    setState(() {
      image = data['picture_url'];
    });
  }
  print('Image:$image');
}

Future<void> assignData() async {
  var userId = FirebaseAuth.instance.currentUser!.uid;
  var querySnapshot = await FirebaseFirestore.instance
      .collection('riders')
      .where('userId', isEqualTo: userId)
      .get();
  
  if (!querySnapshot.docs.isEmpty) {
    var docSnapshot = querySnapshot.docs.first;
    setState(() {
      _plateController.text = docSnapshot.data()['plate_number'] ?? '';
      _modelController.text = docSnapshot.data()['vehicle_model'] ?? '';
      _typeController.text = docSnapshot.data()['vehicle_type'] ?? '';
      _colourController.text = docSnapshot.data()['vehicle_color'] ?? '';
    });
  }
}

  Future<void> changeVehicle() async {
    final user = FirebaseAuth.instance.currentUser;
    final riderRef = FirebaseFirestore.instance.collection('riders');
        await riderRef
            .where('userId', isEqualTo: user!.uid)
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            riderRef.doc(doc.id).update({'plate_number': _plateController.text});
            riderRef.doc(doc.id).update({'vehicle_model':_modelController.text});
            riderRef.doc(doc.id).update({'vehicle_type':_typeController.text});
            riderRef.doc(doc.id).update({'vehicle_color':_colourController.text});
          });
        });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle details updated successfully')));
  }

  Future<void> uploadImage() async {
    if (imageFile == null) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Please select an image first')),
      // );
      return;
    }
    try {
      setState(() => isLoading = true);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      final ref =
          FirebaseStorage.instance.ref().child('riders').child(user.uid).child('vehicle.jpg');

      await ref.putFile(imageFile!);
      final url = await ref.getDownloadURL();
       final riderRef = FirebaseFirestore.instance.collection('riders');
        await riderRef
            .where('userId', isEqualTo: user.uid)
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            riderRef.doc(doc.id).update({'picture_url': url});
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
                context, '/rider_profile', (route) => false);
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
              const SizedBox(height: 20),
              const Text(
                'Update Vehicle Details',
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
                                : ((vehicle_url != null)
                                    ? vehicle_picture!
                                    : Container(
                                        color: Colors.grey,
                                        child: const Center(
                                          child: Text('No image'),
                                        ),
                                      )),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              getImage();
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            child: const Text('Upload Photo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                )),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Select to update',
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Plate Number :'),
                              const SizedBox(height: 10),
                              Container(
                                width: 263,
                                height: 37,
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
                                  controller: _plateController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: InputDecoration(
                                    hintText: "plate number",
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                        255, 249, 249, 249),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
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
                                    prefixIcon: const Icon(
                                      Icons.password,
                                      color: Color(0xFFFFD233),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter plate number';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Vehicle Model : '),
                              const SizedBox(height: 10),
                              Container(
                                width: 263,
                                height: 37,
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
                                  controller: _modelController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: InputDecoration(
                                    hintText: "vehicle model",
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                        255, 249, 249, 249),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
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
                                    prefixIcon: const Icon(
                                      Icons.password,
                                      color: Color(0xFFFFD233),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter vehicle model';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Vehicle Type :'),
                              const SizedBox(height: 10),
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
                                child: DropdownButtonFormField<String>(
                                  value: _selectedVehicleType,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedVehicleType = newValue!;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                        255, 249, 249, 249),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
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
                                      Icons.delivery_dining_outlined,
                                      color: Color(0xFFFFD233),
                                    ),
                                  ),
                                  items:
                                      ["Motorcycle", "Car"].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select vehicle type';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Vehicle Colour :'),
                              const SizedBox(height: 10),
                              Container(
                                width: 263,
                                height: 37,
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
                                  controller: _colourController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: InputDecoration(
                                    hintText: "vehicle colour ",
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                        255, 249, 249, 249),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
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
                                    prefixIcon: const Icon(
                                      Icons.password,
                                      color: Color(0xFFFFD233),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter vehicle colour';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                            ],
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
                            height: 37,
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
                              textAlignVertical: TextAlignVertical.bottom,
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
                                        try {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          passMatch = await checkPassword(
                                              _passwordController.text);
                                          if (_formKey.currentState!
                                              .validate()) {
                                            await uploadImage();
                                            await changeVehicle();
                                            await getData(getID()!);

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Vehicle Detail Updated Successfully')));
                                            Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                '/rider_profile',
                                                (route) => false);
                                          }

                                          setState(() {
                                            isLoading = false;
                                          });
                                        } catch (e) {
                                          return;
                                        }
                                      },
                                child: Container(
                                  width: 135,
                                  height: 53,
                                  alignment: Alignment.center,
                                  decoration: ShapeDecoration(
                                    color:
                                        const Color.fromARGB(255, 44, 174, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: const BorderSide(
                                        width: 1.50,
                                        color: Color.fromARGB(255, 44, 174, 48),
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
    );
  }
}
