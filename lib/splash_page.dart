import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixelpioneer_cpplink/controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userID = currentUser.uid;
      // Query Firestore to determine user role
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        //print('User data: $userData');
        // Check for roles
        if (userData != null &&
            userData['adminId'] != null &&
            userData['adminId'] != '') {
          //print('User is an admin');
          await getAdminData(userID);
          Navigator.of(context).pushReplacementNamed('/admin_home');
        } else if (userData['riderId'] != '') {
          //print('User is a rider');
          await getData(userID);
          await getRiderStatus();
          await checkDelivery();
          await updateListParcel();
          Navigator.of(context).pushReplacementNamed('/rider_home');
        } else {
          //print('User is a customer');
          await getData(userID);
          await updateListParcel();
          Navigator.of(context).pushReplacementNamed('/customer_home');
        }
      } else {
        //print('No user found with that ID');
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else {
      Navigator.of(context)
          .pushReplacementNamed('/login'); // Redirect to login page
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
