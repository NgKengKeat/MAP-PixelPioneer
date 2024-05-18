import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pixelpioneer_cpplink/admin/admin_changeName.dart';
import 'package:pixelpioneer_cpplink/admin/admin_changePassword.dart';
import 'package:pixelpioneer_cpplink/admin/admin_changePhoneNumber.dart';
import 'package:pixelpioneer_cpplink/admin/admin_changeProfilePicture.dart';
import 'package:pixelpioneer_cpplink/admin/admin_homePage.dart';
import 'package:pixelpioneer_cpplink/admin/admin_manageParcel.dart';
import 'package:pixelpioneer_cpplink/admin/admin_manageRider.dart';
import 'package:pixelpioneer_cpplink/admin/admin_quickFind.dart';
import 'package:pixelpioneer_cpplink/admin/admin_quickFindResult.dart';
import 'package:pixelpioneer_cpplink/admin/admin_registerParcel.dart';
import 'package:pixelpioneer_cpplink/admin/admin_scanTrackID.dart';
import 'package:pixelpioneer_cpplink/admin/admin_updateParcel.dart';
import 'package:pixelpioneer_cpplink/admin/admin_updateProfile.dart';
import 'package:pixelpioneer_cpplink/customer/customer_bookingPage.dart';
import 'package:pixelpioneer_cpplink/customer/customer_changeName.dart';
import 'package:pixelpioneer_cpplink/customer/customer_changePassword.dart';
import 'package:pixelpioneer_cpplink/customer/customer_changePhoneNumber.dart';
import 'package:pixelpioneer_cpplink/customer/customer_changeProfilePicture.dart';
import 'package:pixelpioneer_cpplink/customer/customer_homePage.dart';
import 'package:pixelpioneer_cpplink/customer/customer_quickScan.dart';
import 'package:pixelpioneer_cpplink/customer/customer_riderPage.dart';
import 'package:pixelpioneer_cpplink/customer/customer_updateProfile.dart';
import 'package:pixelpioneer_cpplink/customer_register.dart';
import 'package:pixelpioneer_cpplink/delivery/delivery_homePage.dart';
import 'package:pixelpioneer_cpplink/forgotPassword.dart';
import 'package:pixelpioneer_cpplink/registerType_Page.dart';
import 'package:pixelpioneer_cpplink/rider/rider_changeName.dart';
import 'package:pixelpioneer_cpplink/rider/rider_changePassword.dart';
import 'package:pixelpioneer_cpplink/rider/rider_changePhoneNumber.dart';
import 'package:pixelpioneer_cpplink/rider/rider_changeProfilePicture.dart';
import 'package:pixelpioneer_cpplink/rider/rider_changeVehicle.dart';
import 'package:pixelpioneer_cpplink/rider/rider_homePage.dart';
import 'package:pixelpioneer_cpplink/rider/rider_quickScan.dart';
import 'package:pixelpioneer_cpplink/rider/rider_updateProfile.dart';
import 'package:pixelpioneer_cpplink/rider/rider_uploadVehicle.dart';
import 'package:pixelpioneer_cpplink/splash_page.dart';
import 'firebase_options.dart'; // Make sure this is configured with your Firebase options

// import 'customer_pages/customer_quickScan.dart';
// import 'rider_pages/rider_changeProfilePicture.dart';
// import 'admin_pages/admin_homepage.dart';
import 'login_page.dart'; // Assuming you have a login page
// import 'home_page.dart';  // Assuming you have a home page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPPLink Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Define initial route
      initialRoute: '/',
      // Define routes
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register_type': (context) => const RegisterTypePage(),
        '/customer_registration': (context) => const CustomerRegisterPage(),

        //admin
        '/admin_home': (context) => const AdminHomePage(),
        '/admin_profile': (context) => const AdminProfile(),
        '/admin_changeName': (context) => const AdminChangeName(),
        '/admin_changePw': (context) => const AdminChangePassword(),
        '/admin_changePFP': (context) => const AdminChangePicture(),
        '/admin_changePhone': (context) => const AdminChangePhone(),
        '/admin_manageParcel': (context) => const AdminManageParcel(),
        '/admin_updateParcel': (context) => const AdminUpdateParcel(),
        '/admin_registerParcel': (context) => const AdminRegisterParcel(),
        '/admin_manageRider': (context) =>
            const ManageRiderPage(), //! Need done delivery first
        '/admin_quickFind': (context) => const AdminQuickFind(),
        '/admin_quickFindResult': (context) => const AdminQuickFindResult(),
        '/admin_scantrackID': (context) => const AdminScanTrackID(),

        //customer
        '/customer_home': (context) => const CustomerHomepage(),
        '/customer_profile': (context) => const CustomerProfile(),
        '/changeName': (context) => const CustomerChangeName(),
        '/changePw': (context) => const CustomerChangePassword(),
        '/changePFP': (context) => const CustomerChangePicture(),
        '/changePhone': (context) => const CustomerChangePhone(),
        '/customer_booking': (context) => const customerBooking(),  //?Need to check the details for rider
        '/customer_myRider': (context) => const customerRiderPage(name: '', address: '', trackingNumber: '', price: 0,),  //? previously dont have the argument, check!
        //'/customer_checkParcel': (context) => const customerCheckParcel(),
        '/customer_quickScan': (context) => const customerQuickScan(),  //? NO qr code

        // rider
        '/rider_home': (context) => const RiderHomePage(), //!cannot switch to riderMode
        '/rider_changeName': (context) => const RiderChangeName(),
        '/rider_changePw': (context) => const RiderChangePassword(),
        '/rider_changePFP': (context) => const RiderChangePicture(),
        '/rider_changePhone': (context) => const RiderChangePhone(),
        '/rider_profile': (context) => const RiderChangeProfile(),
        '/rider_changeVehicle': (context) => const RiderChangeVehicle(),
        '/rider_vehicle': (context) => const RiderUploadVehicle(),
        // '/rider_booking': (context) => const RiderBooking(),
        // '/rider_myRider': (context) => const RiderRiderPage(),
        //'/rider_checkParcel': (context) => const RiderCheckParcel(),
        '/rider_quickScan': (context) =>
            const RiderQuickScan(), //! NEED to check again with real device android camera, no drop down

//////////////////delivery mode//////////////////////
        '/delivery_homepage': (context) =>
            const DeliveryHomePage(), //! cannot switch to riderMode from rider_home
        // '/delivery_list': (context) => const DeliveryList(),
        // '/delivery_proof': (context) => const DeliveryProof(),
        // '/delivery_qrPage': (context) => const QrCodePage(),
        // '/delivery_profilePage': (context) => const DeliveryProfilePage(),

        '/forgotPassword': (context) => const ForgotPassword(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to CPPLink'),
      ),
      body: const Center(
        child: Text('Main Interface'),
      ),
    );
  }
}
