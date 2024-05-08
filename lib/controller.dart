import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//class Controller {
final currentUser = FirebaseAuth.instance.currentUser;

// Email storage for OTP
String email = '';

void setEmail(String _email) {
  email = _email;
}

String getEmail() {
  return email;
}

var RegisterUserType;
var registerEmail;
var registerPassword;
var registerName;
var registerPhone;
var vehicleModel;
var vehicleColor;
var plateNumber;
var vehicleType;

Future<dynamic> signupRider(var vehicleModel, var vehicleColor, var plateNumber,
    var vehicleType) async {
  try {
    // Create a new user with Firebase Authentication
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: registerEmail,
      password: registerPassword,
    );

    // Get the UID for the newly created user
    String userId = userCredential.user!.uid;

    // Create a user entry in Firestore 'users' collection
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'user_id': userId,
      'email': registerEmail,
      'phone': registerPhone,
      'name': registerName,
      'picture_url': '',
      'adminId': '',
      'created_at': FieldValue.serverTimestamp(),
    });
    // Create a rider entry in Firestore 'riders' collection
    DocumentReference riderRef =
        await FirebaseFirestore.instance.collection('riders').add({
      'userId': userId,
      'vehicle_model': vehicleModel.toString().toUpperCase(),
      'vehicle_color': vehicleColor.toString().toUpperCase(),
      'plate_number': plateNumber.toString().toUpperCase(),
      'vehicle_type': vehicleType.toString().toUpperCase(),
      'picture_url': '',
      'created_at': FieldValue.serverTimestamp(),
    });

    // Retrieve the newly created rider's document ID
    String riderId = riderRef.id;

    // Optionally update the user's document with the rider ID or any additional data
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'riderId': riderId});

    return userId; // Return the user ID of the newly created rider
  } catch (e) {
    return null;
  }
}

// Validate phone format
bool phone_check(String phone) {
  if (!RegExp(r'^01\d{8,9}$').hasMatch(phone)) {
    return false;
  } else {
    return true;
  }
}

// Validate name format
bool name_check(String name) {
  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
    return false;
  } else {
    return true;
  }
}

// Validate email format
bool email_check(String email) {
  if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
      .hasMatch(email)) {
    return false;
  } else {
    return true;
  }
}

//name of user exist //! for admin
Future<bool> user_exist(String name) async {
  final user = await FirebaseFirestore.instance.collection('user').where('name', isEqualTo: name);

  if (user == null) {
    return false;
  } else {
    return true;
  }
}

// Format phone
String formatPhone(String phone) {
  return phone.replaceAll(RegExp(r'\s+'), '').trim();
}

// Format name
String formatName(String name) {
  return name.replaceAll(RegExp(r'\s+'), ' ').trim().toUpperCase();
}

// Format email
String formatEmail(String email) {
  return email.trim();
}

String? getID() {
  return FirebaseAuth.instance.currentUser?.uid;
}

final currentUserID = getID();

Future<void> getRiderDetail(String customerId) async {
  // Access the Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Query the 'booking' collection for entries that match the customer ID and have a status of 'request' or 'accepted'
  var bookingQuery = await firestore
      .collection('booking')
      .where('customer_id', isEqualTo: customerId)
      .where('booking_status', whereIn: ['request', 'accepted']).get();

  // Check if a booking exists and has a rider ID
  if (bookingQuery.docs.isNotEmpty &&
      bookingQuery.docs.first.data()['rider_id'] != null) {
    String riderId = bookingQuery.docs.first.data()['rider_id'];

    // Query the 'rider' collection to get the rider details using the rider ID from the booking
    var riderDoc = await firestore.collection('rider').doc(riderId).get();

    if (riderDoc.exists) {
      // Accessing the data of the rider and potentially related user data
      var riderData = riderDoc.data();
      rider_name = riderData?['name'];
      rider_vehicleType = riderData?['vehicle_type'];
      rider_plate = riderData?['plate_number'];
      rider_model = riderData?['vehicle_model'];
      rider_color = riderData?['vehicle_color'];
      await getVehiclePicture(riderData?[
          'user_id']); // Assuming you have a method to fetch vehicle picture

      print('RIDER_NAME : ' + rider_name);
      rider_exist = true;
    } else {
      print('No rider data available.');
      rider_exist = false;
    }
  } else {
    print('NO RIDER');
    rider_exist = false;
  }

  print("Rider existence status: " + rider_exist.toString());
}

Future<void> getVehiclePicture(String userId) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    var documentSnapshot =
        await firestore.collection('rider').doc(userId).get();

    if (documentSnapshot.exists) {
      var data = documentSnapshot.data();
      vehicle_url = data?['picture_url'];

      if (vehicle_url != null) {
        vehicle_picture = Image.network(
          vehicle_url,
          fit: BoxFit.cover,
          width: 70,
          height: 70,
        );
      }
    } else {
      print("No document found for the given user ID.");
      vehicle_url = null;
      vehicle_picture = null;
    }
  } catch (e) {
    print("Error fetching vehicle picture: $e");
    vehicle_url = null;
    vehicle_picture = null;
  }
}

Future<void> checkBookingStatus(String userId) async {
  // Assuming true, will set to false if any undelivered found
  bool allDelivered = true; 
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Assuming you have a 'parcels' collection where each document represents a parcel
  for (int i = 0; i < user_booking.length; i++) {
    var documentSnapshot = await firestore
        .collection('parcels')
        .where('user_id', isEqualTo: userId)
        .where('tracking_id', isEqualTo: user_booking[i])
        .where('status', isEqualTo: 'delivered')
        .get();

    if (documentSnapshot.docs.isNotEmpty) {
      print('THE STATUS FOR PARCEL ID : ' + user_booking[i] +' IS ' + documentSnapshot.docs.first.data()['status']);
      print('Booking matched and Parcel is delivered!');
    } else {
      print('No Booking matched with this id ' + user_booking[i]);
      allDelivered = false; // Found at least one booking not delivered
      break; // Exit loop early as we found an undelivered booking
    }
  }

  if (allDelivered) {
    show_row = false;
    rider_exist = false;
    delivered = true;
  } else {
    // Handling in case not all are delivered
    delivered = false;
  }
}


var user_name;
var user_phone;
var user_email;
var user_picture;
var picture;
var vehicle_url;
var vehicle_picture;
var user_booking = <String>[];
var user_parcel = <String>[];
var show_row; //show button 'My booking' in homepage
var user_booking_data;
var user_booking_address;
var user_booking_charge_fee;
var selectedValue;
dynamic pass_booking_data;

//booking rider
var rider;
var rider_name;
var rider_vehicleType;
var rider_plate;
var rider_model;
var rider_color;
bool? rider_exist;
bool? delivered;

Future<void> getData(String id) async {
  user_booking = <String>[]; // Reset list
  user_parcel = <String>[];
  selectedValue = null;
  rider_exist = false;
  delivered = false;

  // Get user detail
  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(id).get();

  print('id in getData method is: $id');
  print(userDoc);
  print(userDoc.data());

  if (userDoc.exists) {
    print("Fetched user data: ${userDoc.data()}");
    if (userDoc.data() != null) {
      Map<String, dynamic> data = userDoc.data()!;
      user_name = data['name'];
      user_phone = data['phone'];
      user_email = data['email'];
      user_picture = data['picture_url'];

      if (user_picture != null) {
        picture = Image.network(
          user_picture!,
          fit: BoxFit.cover,
          width: 70,
          height: 70,
        );
      }

       final riderRef = FirebaseFirestore.instance.collection('riders');
      final querySnapshot = await riderRef.where('userId', isEqualTo: id).get();
      final riderData = querySnapshot.docs.first.data();
      if (riderData['rider_id'] == null) {
          getVehiclePicture(id);
      }
    

    } else {
      print("Document is empty!");
    }
  } else {
    print("No such document!");
  }

  // Get customer parcel delivery request with 'accepted' or 'request' status
  final bookingQuerySnapshot = await FirebaseFirestore.instance
      .collection('booking')
      .where('customer_id', isEqualTo: id)
      .where('booking_status', whereIn: ['request', 'accepted']).get();

  if (bookingQuerySnapshot.docs.isNotEmpty) {
    show_row = true;
    var bookingData = bookingQuerySnapshot.docs.first;
    user_booking_address = bookingData.data()['address'];
    user_booking_charge_fee = bookingData.data()['charge_fee'];

    // Assuming each booking has sub-collection or field of parcels
    if (bookingData.data().containsKey('booking_parcel')) {
      for (var parcel in bookingData.data()['booking_parcel']) {
        user_booking.add(parcel['parcel_id']);
      }
    }

    pass_booking_data = bookingData.data();
  } else {
    show_row = false;
    print("no request for this id");
  }

  // Get rider details if needed
  getRiderDetail(id);
}

dynamic riderMode;
Future<void> getRiderStatus() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('No user logged in');
    return;
  }

  final riderDocSnapshot = await FirebaseFirestore.instance
      .collection('riders')
      .doc(
          currentUser.uid) // Assuming the rider's document ID is the user's UID
      .get();

  if (riderDocSnapshot.exists && riderDocSnapshot.data() != null) {
    var riderData = riderDocSnapshot.data()!;
    if (riderData['status'] != 'false') {
      riderMode = true;
    } else {
      riderMode = false;
    }
  } else {
    print('Rider data not found');
    riderMode = false;
  }
}

Future<void> updateRiderStatus(String riderID, String status) async {
  print(riderID);
  try {
    await FirebaseFirestore.instance
        .collection('riders')
        .doc(riderID)
        .update({'status': status});
    print("Status updated successfully.");
  } catch (e) {
    print("Error updating status: $e");
  }
}

//List of elements
var user_data;
var parcel_data;
var requested_parcel;
var rider_parcel_list;
var all_rider_parcel_list;
var all_rider_details;
var user_rider;
var group_parcel;
var rider_parcel_list_delivered = [];
var rider_parcel_list_ongoing = [];

Future<void> getUserList() async {
  try {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('user').get();
    user_data = querySnapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print("Error getting user data: $e");
  }
}

Future<void> getParcelList() async {
  try {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('parcel')
        .orderBy('created_at')
        .get();
    parcel_data = querySnapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print("Error getting parcel data: $e");
  }
}

Future<void> getRequestedParcelList() async {
  try {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('booking')
        .where('booking_status', whereIn: ['request', 'cancelled']).get();
    requested_parcel = querySnapshot.docs
        .map((doc) => {
              ...doc.data(),
              'booking_parcel': doc[
                  'booking_parcel'] // Assuming 'booking_parcel' is a sub-collection or field
            })
        .toList();
  } catch (e) {
    print("Error getting requested parcels: $e");
  }
}

Future<void> getRiderParcel(dynamic riderId) async {
  rider_parcel_list_delivered = [];
  rider_parcel_list_ongoing = [];

  try {
    // Fetch parcels where 'rider_id' matches and sort them if necessary
    var querySnapshot = await FirebaseFirestore.instance
        .collection('booking')
        .where('rider_id', isEqualTo: riderId)
        .get();

    var riderParcelList = querySnapshot.docs.map((doc) => doc.data()).toList();
    riderParcelList = riderParcelList.reversed.toList();

    // Categorize parcels into 'delivered' and 'ongoing'
    for (var parcel in riderParcelList) {
      if (parcel['booking_status'] == 'delivered') {
        rider_parcel_list_delivered.add(parcel);
      } else {
        rider_parcel_list_ongoing.add(parcel);
      }
    }
  } catch (e) {
    print("Error getting rider parcels: $e");
  }
}
