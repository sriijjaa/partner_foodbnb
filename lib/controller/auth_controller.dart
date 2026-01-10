import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/view/auth_screens/login.dart';
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
  final regConfirmPasswordController = TextEditingController();
  final regRestaurantAddress = TextEditingController();
  final regRestaurantDesController = TextEditingController();
  final regPhoneController = TextEditingController();

  //for forget page
  final TextEditingController forgetEmailController = TextEditingController();

  //for edit_profile

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController kitchenNameController = TextEditingController();
  final TextEditingController aboutCooking = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController kitchenAddressController =
      TextEditingController();

  RxBool isLoading = false.obs;
  RxBool isAvailable = true.obs;
  RxBool isAcceptingOrders = true.obs;

  // final FirebaseFirestore firebase = FirebaseFirestore.instanceFor(
  //   app: Firebase.app(),
  //   databaseId: 'firestore-db-foodbnb',
  // );

  final FirebaseFirestore firebase = FirebaseFirestore.instance;

  final FirebaseAuth auth = FirebaseAuth.instance;

  final RxMap userData = {}.obs;

  Future<void> getUserData() async {
    try {
      var snapshot = await firebase
          .collection('moms_kitchens')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      userData.value = snapshot.data() as Map;

      fullNameController.text = userData['ownerName'] ?? '';
      kitchenNameController.text = userData['name'] ?? '';
      aboutCooking.text = userData['description'] ?? '';
      phoneNumberController.text = userData['phone'] ?? '';
      kitchenAddressController.text = userData['locationName'] ?? '';
      log("Got user data: $userData");
    } catch (e) {
      log(e.toString());
    }
  }

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
      String errorMessage = "Login failed";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found for that email.";
      }
      if (e.code == 'wrong-password') errorMessage = "Wrong password provided.";
      if (e.code == 'invalid-email') {
        errorMessage = "The email address is badly formatted.";
      }

      Get.snackbar("Error", errorMessage);
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerUser() async {
    if (regPasswordController.text != regConfirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match!');
      return;
    }
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: regEmailController.text.trim(),
        password: regPasswordController.text.trim(),
      );
      final FirebaseFirestore customDB = FirebaseFirestore.instance;
      //to store data data in
      await customDB
          .collection('moms_kitchens')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({
            "uid": FirebaseAuth.instance.currentUser?.uid,
            "createdAt":
                DateTime.now(), //or we can also give time by using Timestamp.now()
            "cuisine": "",
            "deliveryTime": "",
            "description": regRestaurantDesController.text.trim(),
            "featuredDishImage": "",
            "isVeg": "",
            "location": "",
            "priceForOne": '',
            "profileImage": '',
            'rating': 5,
            'specialties': '',
            'totalOrders': 0,
            "wallet_balance": 0,
            "lifetime_earnings": 0,
            "push_token": "",
            "phone": regPhoneController.text,
            "email": regEmailController.text.trim(),
            "locationName": regRestaurantAddress.text.trim(),
            "name": restaurantNamecontroller.text.trim(),
            "ownerName": nameController.text.trim(),
          }); //if we want to auto set use.set() then set the doc using .doc for adding the Id which is required and .add if we want to add on our own .set to set own docs , for using the id we used the currentuser part.

      // Success: Navigate to Login or Home
      final users = customDB
          .collection('moms_kitchens')
          .doc('5D8QCam2SKZpJ0pgSaZ0T6sz9od2')
          .get();
      print(users);
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

  void logout() {
    try {
      auth.signOut();
      Get.to(() => Login());
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateProfile(String id) async {
    try {
      await firebase.collection('moms_kitchen').doc().update({});
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> forgetPaswword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: forgetEmailController.text.trim(),
      );

      Get.snackbar('Successful', 'Reset Link sent to your Email');
      Get.to(() => Login());
      log("Password reset email sent");
    } catch (e) {
      log("forgetPaswword exception: $e");
    }
  }
}
