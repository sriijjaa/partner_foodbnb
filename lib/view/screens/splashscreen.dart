import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:partner_foodbnb/view/auth_screens/login.dart';
import 'package:partner_foodbnb/view/screens/home_screen.dart';

class Splashscreen extends StatelessWidget {
  Splashscreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3)).then((_) {
      if (_auth.currentUser == null) {
        Get.off(() => Login());
      } else {
        Get.off(() => HomeScreen());
      }
    });

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(30),
              ),
              child: SvgPicture.asset(
                'assets/images/foodbnb1 (3).svg',
                colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
              ),
            ),
            // Lottie.network(
            //   width: double.infinity,

            //   'https://lottie.host/5cf55ee1-e42e-4c1a-a7cb-abb7e6d665ff/1QCvKfU8FJ.json',
            // ),
            Lottie.asset('assets/videos/Cooking.json'),

            SizedBox(height: 4),

            Text(
              "Foodbnb Cook Partner",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "Made at home • Delivered with care",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            SizedBox(height: 32),

            CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
