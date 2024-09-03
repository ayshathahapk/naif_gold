import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../New/NavigationBar/navigation_bar.dart';
import '../../main.dart';
import '../nav_bar.dart';

Position? currentLoc;

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // getLocation1() async {
  //   try {
  //     currentLoc = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
  //     print("======================location$currentLoc");
  //   } catch (err) {
  //     print("========================err${err.toString()}");
  //   }
  // }
  // Future<void> requestLocationPermission() async {
  //   PermissionStatus status;
  //
  //   do {
  //     status = await Permission.location.request();
  //
  //     if (status.isGranted) {
  //       await getLocation1();
  //     }
  //     if (status.isPermanentlyDenied) {
  //       openAppSettings();
  //     }
  //
  //
  //   } while (status.isDenied);
  //   await Future.delayed(Duration(seconds: 2));
  // }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(Duration(seconds: 4), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigationBarScreen()),
          // MaterialPageRoute(builder: (context) => Navpage()),
        );
      });
    });
    // getLocation1();
    // requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      backgroundColor: Color(0xFF124139),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: height * 0.3,
              width: width * 0.3,
              child: Image.asset(
                'asset/images/Naif-Logo.png',
              ),
            ),
            SizedBox(
                height: 1), // Add some space between the image and the text
            Container(
              color: Color(0xFF124139),
              child: Text(
                'DUBAI       ABU DHABI     AL AIN' ' SHARJAH  KSA',
                style: TextStyle(
                    color: Color(
                        0xFFBFA13A), // White text color for better visibility on a black background
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
