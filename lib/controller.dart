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
      'name': registerName,
      'phone':registerPhone,
      'userId': userId,
      'vehicle_model': vehicleModel.toString().toUpperCase(),
      'vehicle_color': vehicleColor.toString().toUpperCase(),
      'plate_number': plateNumber.toString().toUpperCase(),
      'vehicle_type': vehicleType.toString().toUpperCase(),
      'picture_url': '',
      'status': 'offline',
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
  final user = await FirebaseFirestore.instance
      .collection('user')
      .where('name', isEqualTo: name);

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

String? currentUserID = getID();

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
      var riderData = riderDoc.data();
      rider_name = riderData?['name'];
      rider_vehicleType = riderData?['vehicle_type'];
      rider_plate = riderData?['plate_number'];
      rider_model = riderData?['vehicle_model'];
      rider_color = riderData?['vehicle_color'];
      await getVehiclePicture(riderData?[
          'user_id']); 

      // print('RIDER_NAME : ' + rider_name);
      rider_exist = true;
    } else {
      // print('No rider data available.');
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
  for (int i = 0; i < user_booking.length; i++) {
    var documentSnapshot = await firestore
        .collection('parcels')
        .where('user_id', isEqualTo: userId)
        .where('tracking_id', isEqualTo: user_booking[i])
        .where('status', isEqualTo: 'delivered')
        .get();

    if (documentSnapshot.docs.isNotEmpty) {
      print('THE STATUS FOR PARCEL ID : ' +
          user_booking[i] +
          ' IS ' +
          documentSnapshot.docs.first.data()['status']);
      // print('Booking matched and Parcel is delivered!');
    } else {
      // print('No Booking matched with this id ' + user_booking[i]);
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
  user_booking = <String>[];
  user_parcel = <String>[];
  selectedValue = null;
  rider_exist = false;
  delivered = false;

  // Get user detail
  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(id).get();

  // print('id in getData method is: $id');
  // print(userDoc);
  // print(userDoc.data());

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
      if (querySnapshot.docs.isNotEmpty) {
        final riderData = querySnapshot.docs.first.data();
        if (riderData['rider_id'] == null) {
          getVehiclePicture(id);
        }
      } else {
        print("No rider data found for this user");
      }
    } else {
      print("Document is empty!");
    }
  } else {
    print("No such document!");
  }

  //select all customer parcel with 'arrived' status to display
  getArrivedParcel(id);

  // Get customer parcel delivery request with 'accepted' or 'request' status
  final bookingQuerySnapshot = await FirebaseFirestore.instance
      .collection('booking')
      .where('customer_id', isEqualTo: id)
      .where('booking_status', whereIn: ['request', 'accepted']).get();

  if (bookingQuerySnapshot.docs.isNotEmpty) {
    show_row = true;
    var bookingData = bookingQuerySnapshot.docs.first;
    user_booking_address = bookingData.data()['address'];
    user_booking_charge_fee = bookingData.data()['charge_price'];

    // Assuming each booking has sub-collection or field of parcels
    if (bookingData.data().containsKey('booking_parcel')) {
      for (var parcel in bookingData.data()['booking_parcel']) {
        user_booking.add(parcel['parcel_id']);
      }
    }

    pass_booking_data = bookingData.data();
  } else {
    show_row = false;
    // print("no request for this id");
  }

  // Get rider details if needed
  getRiderDetail(id);
}

dynamic riderMode;
Future<void> getRiderStatus() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    // print('No user logged in');
    return;
  }

  final riderDocSnapshot = await FirebaseFirestore.instance
      .collection('riders')
      .where('userId', isEqualTo: currentUser.uid)
      .get();

  if (riderDocSnapshot.docs.isNotEmpty) {
    var riderDoc = riderDocSnapshot.docs.first;
    var riderData = riderDoc.data();
    if (riderData['status'] != 'offline') {
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
  try {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('riders')
        .where('rider_id', isEqualTo: riderID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        // Check current status before updating
        Map<String, dynamic> riderData = doc.data();
        String currentStatus = riderData['status'];

        if (currentStatus != 'delivering') {
          await FirebaseFirestore.instance
              .collection('riders')
              .doc(doc.id)
              .update({'status': status});

          print("Status updated successfully.");
        } else {
          print("Rider is already delivering. Status not updated.");
        }
      }
    } else {
      print("No rider found with rider_id: $riderID");
    }
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
var rider_parcel_list_accepted = [];

Future<void> getUserList() async {
  try {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('user').get();
    user_data = querySnapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    // print("Error getting user data: $e");
  }
}

Future<void> getParcelList() async {
  try {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('parcels')
        .orderBy('created_at')
        .get();
    parcel_data = querySnapshot.docs.map((doc) => doc.data()).toList();
    print('Retrieved parcel data: $parcel_data');
  } catch (e) {
    print("Error getting parcel data: $e");
  }
}

// Future<void> getRequestedParcelList() async
// {
//   try {
//     var querySnapshot = await FirebaseFirestore.instance
//         .collection('booking')
//         .where('booking_status', whereIn: ['request', 'cancelled']).get();
//     requested_parcel = querySnapshot.docs
//         .map((doc) => {
//               ...doc.data(),
//               'booking_parcel': doc[
//                   'booking_parcel']
//             })
//         .toList();
//   }
//   catch (e)
//   {
//     print("Error getting requested parcels: $e");
//   }
// }

// Future<void> getRequestedParcelList() async {
//   try {
//     var querySnapshot = await FirebaseFirestore.instance
//         .collection('booking')
//         .where('booking_status', isEqualTo: 'request')
//         .get();
//     requested_parcel = querySnapshot.docs
//         .map((doc) => doc.data())
//         .toList();
//   } catch (e) {
//     print("Error getting requested parcels: $e");
//   }
// }

// Future<void> getRequestedParcelList() async
// {
//   try {
//     var querySnapshot = await FirebaseFirestore.instance
//         .collection('booking')
//         .where('booking_status', whereIn: ['request', 'cancelled']).get();
//     requested_parcel = querySnapshot.docs
//         .map((doc) => {
//               ...doc.data(),
//               'booking_parcel': doc[
//                   'booking_parcel']
//             })
//         .toList();
//   } catch (e) {
//     print("Error getting requested parcels: $e");
//   }
// }

Future<void> getRiderParcel(String riderId) async {
  rider_parcel_list_delivered = [];
  rider_parcel_list_ongoing = [];
  rider_parcel_list_accepted = [];

  try {
    // Fetch parcels where 'rider_id' matches and sort them if necessary
    var querySnapshot = await FirebaseFirestore.instance
        .collection('booking')
        .where('rider_id', isEqualTo: riderId)
        .get();

    var riderParcelList = querySnapshot.docs.map((doc) => doc.data()).toList();
    riderParcelList = riderParcelList.reversed.toList();

    for (var parcel in riderParcelList) {
      if (parcel['booking_status'] == 'delivered') {
        rider_parcel_list_delivered.add(parcel);
      }
      if (parcel['booking_status'] == 'ongoing') {
        rider_parcel_list_ongoing.add(parcel);
      }
      if (parcel['booking_status'] == 'accepted') {
        rider_parcel_list_accepted.add(parcel);
      }
    }
  } catch (e) {
    print("Error getting rider parcels: $e");
  }
}

var admin_name;
var admin_phone;
var admin_email;
var admin_picture;
var picture_url;

Future<void> getAdminData(dynamic userId) async {
  // var userId = FirebaseAuth.instance.currentUser!.uid;
  var adminRef = FirebaseFirestore.instance.collection('admin');
  var adminQuery =
      await adminRef.where('user_id', isEqualTo: userId).limit(1).get();

  if (adminQuery.docs.isNotEmpty) {
    var data = adminQuery.docs.first.data();
    admin_name = data['name'];
    admin_phone = data['phone'];
    admin_email = data['email'];
    picture_url = data['picture_url'];

    if (picture_url != null && picture_url.isNotEmpty) {
      admin_picture = Image.network(
        picture_url,
        fit: BoxFit.cover,
        width: 70,
        height: 70,
      );
    }
  } else {
    print('No admin data found');
  }
}

var allRider_parcel_list_status = <String>[];
List<Map<String, dynamic>> allRider_parcel_list_user = [];
var allRider_parcel_list_booking = [];
var rider_parcel_list_bookingID = [];
List<List<dynamic>> listParcelID = [];

Future<void> getListBookingParcelID(String bookingID) async {
  rider_parcel_list_bookingID = [];
  var querySnapshot = await FirebaseFirestore.instance
      .collection('booking')
      .where('tracking_id', isEqualTo: bookingID)
      .get();

  for (var doc in querySnapshot.docs) {
    var parcelId = doc.data()['parcel_id'];
    if (parcelId != null) {
      rider_parcel_list_bookingID.add(parcelId);
    }
  }
  print(rider_parcel_list_bookingID);
}


Future<void> getAllRiderParcel() async {
  print("entering getAllRiderParcel");
  //List<Map<String, dynamic>> allRider_parcel_list_user = [];
  allRider_parcel_list_status = <String>[];
  allRider_parcel_list_user = [];
  allRider_parcel_list_booking = [];
  List<List<String>> listParcelID = [];

  try {
    // Fetch all riders
    QuerySnapshot riderSnapshot =
        await FirebaseFirestore.instance.collection('riders').get();
   
    // Iterate over each rider document
    for (var riderDoc in riderSnapshot.docs) {
      var riderData = riderDoc.data() as Map<String, dynamic>;

       print(riderData['rider_id']);

      if (riderData['status'] == 'delivering') {
        // Fetch bookings for the current rider
        QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
            .collection('booking')
            .where('rider_id', isEqualTo: riderData['rider_id'])
            .get();

        List<Map<String, dynamic>> bookings = [];
        for (var bookingDoc in bookingSnapshot.docs) {
          var bookingData = bookingDoc.data() as Map<String, dynamic>;
          // print("BookingData: ");
          // print(bookingData);

          if (bookingData['booking_status'] == 'accepted') {
            // Fetch parcel IDs related to the booking
            QuerySnapshot parcelSnapshot = await FirebaseFirestore.instance
                .collection('parcels')
                .where('tracking_id', isEqualTo: bookingData['tracking_id'])
                .get();

            List<String> parcelList = [];
            // print("Parcel Doc:");
            // print( parcelSnapshot.docs);
            for (var parcelDoc in parcelSnapshot.docs) {
              parcelList.add(parcelDoc.id);
              // print(parcelList);
            }

            // Add parcel list to the booking data
            bookingData['parcelList'] = parcelList;
            listParcelID.add(parcelList);
          } else {
            listParcelID.add([]);
          }

          bookings.add(bookingData);
         // print("Booking for bookingData:" );
          // print(bookings);
        }
        // Add bookings to the rider data
        riderData['booking'] = bookings;
      }

      allRider_parcel_list_user.add(riderData);
      // print("allRider_parcel_list_user");
      // print(allRider_parcel_list_user);
    }
  } catch (e) {
    // print("Error fetching data: $e");
  }
  
}


bool findParcelStatus = false;
var tracking_id;
var customerName;
var customerNumber;
var dateArrived;
var status;
var shelf_number;

Future<void> findParcel(dynamic searchParcel) async {
  try {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('parcels')
        .where('tracking_id', isEqualTo: searchParcel)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If at least one document is found
      var parcelData = querySnapshot.docs.first.data();
      tracking_id = parcelData['tracking_id'] as String?;
      customerName = parcelData['name'] as String?;
      customerNumber = parcelData['phone'] as String?;
      dateArrived = (parcelData['date_arrived'] as Timestamp?)?.toDate();
      status = parcelData['status'] as String?;
      shelf_number = parcelData['shelf_number'] as String?;

      // print('My track ID is $tracking_id and the status is $status');
      findParcelStatus = true;
    } else {
      // Reset values if no parcel is found
      tracking_id = null;
      customerName = null;
      customerNumber = null;
      dateArrived = null;
      status = null;
      shelf_number = null;
      // print('Parcel not found for tracking_id: $searchParcel');
    }
  } catch (error) {
    // Handle any errors that occur during fetch operation
    // print('Error fetching parcel data: $error');
  }
}

//update parcel data
var edit_parcel;

Future<bool> parcel_unique(String parcelId) async {
  // Query Firestore to check if a parcel with the given tracking_id exists
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('parcels')
      .where('tracking_id', isEqualTo: parcelId)
      .limit(1) // Limit the results to 1 for efficiency
      .get();

  // Check if the query returned any documents
  if (querySnapshot.docs.isEmpty) {
    return true; 
  } else {
    return false; 
  }
}

var booking_index;

List<String> list_name = <String>[];
List<String> list_phone = <String>[];
dynamic list_user;

Future<void> userNameList() async {
  // print("entering userNameList in controller");
  // list_name.clear();
  // list_phone.clear();
  list_name = [];
  list_phone = [];

  try {
    // Query Firestore to get all users and their names and phones
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Iterate over the documents returned by the query
    for (var doc in querySnapshot.docs) {
      var data =
          doc.data() as Map<String, dynamic>?; // Safely cast as a nullable Map
      if (data != null) {
        String name = data['name'] ?? '';
        String phone = data['phone'] ?? '';

        list_name.add(name);
        list_phone.add(phone);

        // print(list_name);
        // print(list_phone);
      }
    }
  } catch (e) {
    // print('Error fetching user list: $e');
  }
}

// Function to fetch arrived parcels for a specific user
Future<List<String>> getArrivedParcel(dynamic userId) async {
  List<String> userParcels = [];

  try {
    // Query Firestore to find parcels with 'arrived' status for the specified user
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('parcels')
        .where('user_id', isEqualTo: userId)
        .where('status', isEqualTo: 'arrived')
        .get();

    // Extract tracking IDs from the query results
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('tracking_id')) {
        userParcels.add(data['tracking_id']);
      }
    }
  } catch (e) {
    // print('Error fetching arrived parcels: $e');
  }

  return userParcels;
}

var dropdownValues;

// Function to update the list of parcels and set the dropdown value
Future<void> updateListParcel() async {
  user_parcel = await getArrivedParcel(currentUserID!);

  if (user_parcel.isNotEmpty) {
    dropdownValues =
        user_parcel[0]; // Set the first parcel as the default selection
  } else {
    dropdownValues = ""; // Set to empty string if no parcels are arrived
  }
}

bool isDeliver = false;

Future<void> checkDelivery() async {
  isDeliver = false;
  try {
    var riderId = user_rider[0]
        ['rider_id']; 
    var deliverySnapshot = await FirebaseFirestore.instance
        .collection('booking')
        .where('rider_id', isEqualTo: riderId)
        .where('booking_status', isEqualTo: 'accepted')
        .get();

    // Check if any documents are returned
    isDeliver = deliverySnapshot.docs.isNotEmpty;
  } catch (e) {
   //  print("Error checking delivery: $e");
  }
}

