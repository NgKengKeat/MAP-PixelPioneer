import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pixelpioneer_cpplink/controller.dart';

class DeliveryProfilePage extends StatefulWidget {
  const DeliveryProfilePage({super.key});

  @override
  State<DeliveryProfilePage> createState() => _DeliveryProfilePageState();
}

class _DeliveryProfilePageState extends State<DeliveryProfilePage> {
  double totalIncome = 0;
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

Future<void> fetchTotalIncome() async {
    double income = 0;

    try {
      // Query Firestore to find documents where 'rider_id' matches
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('booking')
          .where('rider_id', isEqualTo: currentUserID)
          .where('booking_status', isEqualTo: 'accepted')
          .get();

      // Iterate over the documents and sum up the 'charge_price' values
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data != null && data['charged_price'] != null) {
          // Ensure data['charge_price'] is an int before adding
          if (data['charged_price'] is int) {
            income += data['charged_price'] as int;
          } else {
            print('charge_price is not of type int for document ${doc.id}');
            continue; // Skip this document if charge_price is not int
          }
        }
      }

      setState(() {
        totalIncome = income;
      });

      print('Total income calculated: \$${totalIncome.toString()}');

    } catch (e) {
      print('Failed to calculate total income: $e');
    }
  }


  @override
  void initState() {
    super.initState();
   fetchTotalIncome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(248, 134, 41, 1),
        centerTitle: true,
        title: const Text(
          'Rider Profile',
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
            Navigator.of(context).pushReplacementNamed('/delivery_homepage');
            // Your code to handle the tap event
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
                                    color: const Color.fromRGBO(
                                        248, 134, 41, 1), // Border color
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
                                      user_name ?? 'Loading...',
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
                                          color:
                                              Color.fromRGBO(248, 134, 41, 1),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          user_phone ?? 'Loading...',
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
                                          color:
                                              Color.fromRGBO(248, 134, 41, 1),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          user_email ?? 'Loading...',
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
                      Column(
                        children: [
                          const Text(
                            'Total Deliveries :',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                              height: 0.00,
                            ),
                          ),
                          Text(
                            rider_parcel_list_accepted.length.toString(),
                            style: const TextStyle(
                              color: Color.fromRGBO(248, 134, 41, 1),
                              fontSize: 50,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                              height: 0.00,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Column(
                        children: [
                          const Text(
                            'Total Income :',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                              height: 0.00,
                            ),
                          ),
                          Text(
                            totalIncome.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Color.fromRGBO(248, 134, 41, 1),
                              fontSize: 50,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                              height: 0.00,
                            ),
                          ),
                        ],
                      ),
                    ]),

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
    );
  }
}
