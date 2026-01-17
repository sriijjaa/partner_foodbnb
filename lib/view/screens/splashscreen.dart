import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/view/auth_screens/login.dart';
import 'package:partner_foodbnb/view/screens/home_screen.dart';

class Splashscreen extends StatelessWidget {
  Splashscreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2)).then((_) {
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
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Image.asset('', height: 100, width: 100),
            ),

            SizedBox(height: 24),

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
