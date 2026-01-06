import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/view/ui_screens/home_screen.dart';

class AuthController extends GetxController {
  // for login page
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // for register page
  final nameController = TextEditingController();
  final restaurantNamecontroller = TextEditingController();
  final regEmailController = TextEditingController();
  final regPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final restaurantAddress = TextEditingController();

  //for forget page
  final TextEditingController forgetEmailController = TextEditingController();
  final TextEditingController forgetPasswordController =
      TextEditingController();
  final TextEditingController forgetConfirmPasswordController =
      TextEditingController();

  RxBool isLoading = false.obs;

  final FirebaseFirestore firebase = FirebaseFirestore.instance;

  Future<void> handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Please fill in all fields")),
      // ); 
      
      //get.snackbar instead of snackbar in scaffoldMessenger, no mount and earlier navigation method in Getx ,title for showing msg at top of the app and msg to display the msg that we want after the action

      Get.snackbar("Error", "Please fill in all fields");
      return;
    }

    // setState(() => isLoading = true); instead we use only the variable then .value to get the value

    isLoading.value = true;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Get.to(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      // Handle errors (Wrong password, no user found, etc.)
      String errorMessage = "Login failed";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found for that email.";
      }
      if (e.code == 'wrong-password') errorMessage = "Wrong password provided.";
      if (e.code == 'invalid-email') {
        errorMessage = "The email address is badly formatted.";
      }

      Get.snackbar("Error", errorMessage);
    } 
    
    
    finally {
      isLoading.value = false;
    }
  }

  Future<void> registerUser() async {
    if (regPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match!');
      return;
    }
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: regEmailController.text.trim(),
        password: regPasswordController.text.trim(),
      );

      //to store data in firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set(
            {
              "email": regEmailController.text.trim(),
              "name": nameController.text.trim(),
              "joined_at":
                  DateTime.now(), //or we can also give time by Timestamp.now()
              "uid": FirebaseAuth.instance.currentUser?.uid,
              "user_type": "restaurant",
              "address": restaurantAddress.text.trim(),
              "push_token": "",
              "restaurant_name": restaurantNamecontroller.text.trim(),
              "wallet_balance": 0,
              "lifetime_earnings": 0,
            },
          ); //if we want to auto set use.set() then set the doc using .doc for adding the Id which is required and .add if we want to add on our own .set to set own docs , for using the id we used the currentuser part.

      // Success: Navigate to Login or Home

      Get.snackbar('Success', 'Account Registered Successfully');
      Get.to(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'weak-password') message = "The password is too weak.";
      if (e.code == 'email-already-in-use') message = "Email already in use.";

      Get.snackbar('Error', message);
    } finally {
      isLoading.value = false;
    }
  }
}
