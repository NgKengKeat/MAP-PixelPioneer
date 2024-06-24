import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:pixelpioneer_cpplink/controller.dart';
import 'package:pixelpioneer_cpplink/delivery/delivery_deliveryList.dart';
import '../main.dart';

class DeliveryProof extends StatefulWidget {
  const DeliveryProof({super.key});

  @override
  State<DeliveryProof> createState() => _DeliveryListSProof();
}

class _DeliveryListSProof extends State<DeliveryProof> {
  dynamic image;
  XFile? fileImage;
  File? imageFile;
  bool isImageSelected = false;
  bool isLoading = false;
  String _selectedStatusType = 'Delivered';
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

 Future<void> uploadImage(File fileImage) async 
 {
  try 
  {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;


    final imageExtension = fileImage.path.split('.').last.toLowerCase();
    final imageBytes = await fileImage.readAsBytes();


    final base64Image = 'data:image/$imageExtension;base64,${base64Encode(imageBytes)}';


    final trackingId = riderParcelList[booking_index]['tracking_id'];
    final riderId = riderParcelList[booking_index]['rider_id'];

   
    QuerySnapshot querySnapshot = await firestore.collection('booking')
        .where('tracking_id', isEqualTo: trackingId)
        .where('rider_id', isEqualTo: riderId)
        .get();

 
    if (querySnapshot.docs.isNotEmpty) {

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
       
        await doc.reference.update({
          'picture_url': base64Image,
        });
      }
      // Print confirmation
     //  print('Picture URL updated successfully');
    } else {
     // print('No documents matched the query');
    }

  } catch (e) {
    // print('Failed to update picture URL: $e');
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

 Future<void> completeDelivery() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  final trackingId = riderParcelList[booking_index]['tracking_id'];

  try {

    QuerySnapshot bookingSnapshot = await firestore
        .collection('booking')
        .where('tracking_id', isEqualTo: trackingId)
        .get();

    for (QueryDocumentSnapshot doc in bookingSnapshot.docs) {
      await doc.reference.update({
        'booking_status': 'delivered',
      });
    }

    // Print confirmation
    print('Booking status updated successfully to delivered.');

    // Update rider status to 'idle'
    String riderId = currentUserID; // Assuming currentUserID is correctly defined
    QuerySnapshot riderSnapshot = await firestore
        .collection('riders')
        .where('rider_id', isEqualTo: riderId)
        .get();

    if (riderSnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot doc in riderSnapshot.docs) {
        await doc.reference.update({
          'status': 'delivering',
        });
      }
      print('Rider status updated to idle.');
    } else {
      print('No rider found with rider_id: $riderId');
    }

  } catch (e) {
    print('Failed to complete delivery: $e');
  }
 }


  Future<void> changePage() async {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/delivery_list', (route) => false);
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
          backgroundColor: const Color.fromRGBO(248, 134, 41, 1),
          centerTitle: true,
          title: const Text(
            'Complete Delivery',
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
              Navigator.of(context).pushReplacementNamed('/delivery_list');
            },
          ),
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Complete Delivery',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 38,
                          fontFamily: 'Montagu Slab',
                          fontWeight: FontWeight.w400,
                          height: 0.00,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ///////////////////////////
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Details :',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 17,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              height: 0.00,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 1),
                          borderRadius: BorderRadius.circular(10),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // if (rider_parcel_list_ongoing != null &&
                              //     rider_parcel_list_ongoing.length > 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /////////////
                                  ////////////
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          const Column(
                                            children: [
                                              Text(
                                                'Track Num. : ',
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
                                          Column(
                                            children: [
                                              Text(
                                                rider_parcel_list_ongoing
                                                        .isEmpty
                                                    ? 'Loading...'
                                                    : rider_parcel_list_ongoing[
                                                                booking_index]
                                                         
                                                        ['tracking_id'],
                                                    
                                                style: const TextStyle(
                                                  color: Color(0xFF333333),
                                                  fontSize: 17,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w400,
                                                  height: 0.00,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Name : ',
                                        style: TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 17,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400,
                                          height: 0.00,
                                        ),
                                      ),
                                      Text(
                                        rider_parcel_list_ongoing.isEmpty
                                            ? 'Loading...'
                                            : rider_parcel_list_ongoing[
                                                        booking_index]
                                                   ['name'],
                                        style: const TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 17,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400,
                                          height: 0.00,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Phone : ',
                                        style: TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 17,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400,
                                          height: 0.00,
                                        ),
                                      ),
                                      Text(
                                        rider_parcel_list_ongoing.isEmpty
                                            ? 'Loading...'
                                            : rider_parcel_list_ongoing[
                                                booking_index]['phone'],
                                        style: const TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 17,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400,
                                          height: 0.00,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Address : ',
                                        style: TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 17,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400,
                                          height: 0.00,
                                        ),
                                      ),
                                      Text(
                                        rider_parcel_list_ongoing.isEmpty
                                            ? 'Loading...'
                                            : rider_parcel_list_ongoing[
                                                    booking_index]['address'] ??
                                                'MA1,KTDI',
                                        style: const TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 17,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400,
                                          height: 0.00,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              // Adjust the spacing between columns
                              // Right column with data
                            ],
                          ),
                        ),
                      ),
                      //////////////////////////
                      const SizedBox(height: 30),
                      ///////////////////////////
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Status :',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 17,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              height: 0.00,
                            ),
                          ),
                        ],
                      ),
                      //////////////////////////
                      const SizedBox(height: 10),
                      ///////////////////////////
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 1),
                          borderRadius: BorderRadius.circular(10),
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
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Status : ', 
                                    style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 17,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                      height: 0.00,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          width: 0.5,
                                          color: const Color.fromARGB(56, 25, 25, 25),
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color.fromARGB(
                                                164, 117, 117, 117),
                                            blurRadius: 4,
                                            offset: Offset(0, 4),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedStatusType,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _selectedStatusType = newValue!;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color.fromARGB(
                                              255, 249, 249, 249),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 10,
                                          ),
                                        ),
                                        items:
                                            ["Delivered"].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select status type';
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Proof: ', 
                                    style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 17,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                      height: 0.00,
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  Column(
                                    children: [
                                      Container(
                                        width: 160,
                                        height: 160,
                                        color: const Color.fromARGB(255, 156, 156,
                                            156), // Set the background color to blue
                                        child: isImageSelected == true
                                            ? Image(
                                                image: FileImage(imageFile!))
                                            : const Center(
                                                child: Text('No image'),
                                              ),
                                      ),
                                      Container(
                                        width: 150,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            getImage();
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.blue),
                                          ),
                                          child: const Text(
                                            'Upload Photo',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: 'Lexend',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      /////////////////////////////
                      const SizedBox(height: 20),
                      /////////////////////////////
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await uploadImage(imageFile!);
                          await completeDelivery();
                          await getData(currentUserID);
                          await getRiderParcel(currentUserID);
                          print('upload button press');
                          await changePage();
                          Fluttertoast.showToast(
                            msg: "Delivery completed!",
                          );
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: Container(
                          width: 263,
                          height: 53,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color.fromARGB(255, 44, 174, 48),
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
                          child: isLoading == false
                              ? const Text(
                                  'Confirm',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color.fromARGB(
                                        255, 255, 255, 255),
                                    fontSize: 15,
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              : const Text(
                                  'Loading..',
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
