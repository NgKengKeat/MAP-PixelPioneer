import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixelpioneer_cpplink/controller.dart';

import '../main.dart';

// ignore: camel_case_types
class customerRiderPage extends StatefulWidget {
  const customerRiderPage({super.key});

  @override
  State<customerRiderPage> createState() => customerBbookingState();
}

// ignore: camel_case_types
class customerBbookingState extends State<customerRiderPage> 
{
  bool isImageSelected = false;
  XFile? fileImage;
  File? imageFile;
  String user_name="";
  final currentuser = FirebaseAuth.instance.currentUser?.uid;

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
  void initState() 
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(250, 195, 44, 1),
        centerTitle: true,
        title: const Text(
          'My Rider',
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'My Rider',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 38,
                    fontFamily: 'Montagu Slab',
                    fontWeight: FontWeight.w400,
                    height: 0.00,
                  ),
                ),
                /////////////////////////////
                const SizedBox(
                  height: 40,
                ),
                /////////////////////////////
                const Row(
                  children: [
                    Text(
                      'Parcel details: ',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 0.00,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                /////////////////////////////
                Container(
                  alignment: AlignmentDirectional.topStart,
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
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2.2),
                            1: FlexColumnWidth(3),
                          },
                          children: [
                            TableRow(children: [
                              const Text(
                                'Tracking Number : ',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 17,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 0.00,
                                ),
                              ),
                              Text(
                                user_booking.join(', '),
                                style: const TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 17,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 0.00,
                                ),
                              )
                            ])
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
                              user_booking_address.toString(),
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
                              user_name,
                              style: const TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 17,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                height: 0.00,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                ////////////////////////////
                const SizedBox(height: 30),
                const Row(
                  children: [
                    Text(
                      'Rider details: ',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 0.00,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                /////////////////////////////
                ///////////////////////////
                rider_exist == false
                    ? const Text('no rider')
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 87, 255, 93),
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
                          padding: const EdgeInsets.only(
                              top: 20, left: 10, right: 10, bottom: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      width: 120,
                                      height: 150,
                                      child: (vehicle_url != null)
                                          ? vehicle_picture!
                                          : Container(
                                              color: Colors.grey,
                                              child: const Center(
                                                child: Text('No image'),
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rider_name, // Replace with actual data
                                          style: const TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 17,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
                                            height:
                                                1.2, // Adjust the height as needed
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Vehicle Details : ',
                                          style: TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 17,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w700,
                                            height: 0.00,
                                          ),
                                        ),
                                        Text(
                                          rider_vehicleType,
                                          style: const TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 17,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                            height: 0.00,
                                          ),
                                        ),
                                        Text(
                                          rider_plate,
                                          style: const TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 17,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                            height: 0.00,
                                          ),
                                        ),
                                        Text(
                                          rider_model,
                                          style: const TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 17,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                            height: 0.00,
                                          ),
                                        ),
                                        Text(
                                          rider_color,
                                          style: const TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 17,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                            height: 0.00,
                                          ),
                                        ),
                                        const SizedBox(height: 10)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                //////////////////////////////////
                /////////////////////////////////
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Charge : ',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 0.00,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'RM',
                      style: TextStyle(
                        color: Color.fromARGB(255, 14, 173, 19),
                        fontSize: 30,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 0.00,
                      ),
                    ),
                    Text(
                      user_booking_charge_fee.toString(),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 14, 173, 19),
                        fontSize: 30,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 0.00,
                      ),
                    ),
                    const Text(
                      '.00',
                      style: TextStyle(
                        color: Color.fromARGB(255, 14, 173, 19),
                        fontSize: 30,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 0.00,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                /////////////////////////////
                ////////////////////////////////
              ],
            ),
          ),
        ],
      ),
    );
  }
}