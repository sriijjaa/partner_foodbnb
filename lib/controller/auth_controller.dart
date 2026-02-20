import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:partner_foodbnb/view/auth_screens/login.dart';
import 'package:partner_foodbnb/view/auth_screens/register.dart';
import 'package:partner_foodbnb/view/screens/home_screen.dart';

class AuthController extends GetxController {
  // for login page
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // for register page

  String? selectedPreference;

  final nameController = TextEditingController();
  final kitchenNamecontroller = TextEditingController();
  final regEmailController = TextEditingController();
  final regPasswordController = TextEditingController();
  final regConfirmPasswordController = TextEditingController();
  final regKitchenAddress = TextEditingController();
  final regKitchenDesController = TextEditingController();
  final regPhoneController = TextEditingController();
  final regFoodpreferenceController = TextEditingController();

  final regCuisineController = TextEditingController();
  final regSpecialityController = TextEditingController(); // Temporary input
  final RxList<String> specialitiesList =
      <String>[].obs; // Store multiple specialities

  final regPanNumberController = TextEditingController();
  final regFssaiNumberController = TextEditingController();

  // Open and close time
  Rx<TimeOfDay?> openTime = Rx<TimeOfDay?>(null);
  Rx<TimeOfDay?> closeTime = Rx<TimeOfDay?>(null);

  //for forget page
  final TextEditingController forgetEmailController = TextEditingController();

  //for edit_profile
  final TextEditingController editFullNameController = TextEditingController();
  final TextEditingController editKitchenNameController =
      TextEditingController();
  final TextEditingController editAboutCooking = TextEditingController();
  final TextEditingController editPhoneNumberController =
      TextEditingController();
  final TextEditingController editKitchenAddressController =
      TextEditingController();
  final TextEditingController editCuisineController = TextEditingController();
  final TextEditingController editSpecialityController =
      TextEditingController();
  final RxList<dynamic> editSpecialitiesList = <dynamic>[].obs;
  final TextEditingController editPanController = TextEditingController();
  final TextEditingController editEmailController = TextEditingController();
  // Edit profile open and close time
  Rx<TimeOfDay?> editOpenTime = Rx<TimeOfDay?>(null);
  Rx<TimeOfDay?> editCloseTime = Rx<TimeOfDay?>(null);

  RxBool isLoading = false.obs;
  RxBool isAvailable = true.obs;
  RxBool isAcceptingOrders = true.obs;
  RxString profilePhotoUrl = ''.obs;

  // Password visibility toggle for create password field
  RxBool isPasswordVisible = false.obs;

  // final FirebaseFirestore firebase = FirebaseFirestore.instanceFor(
  //   app: Firebase.app(),
  //   databaseId: 'firestore-db-foodbnb',
  // );

  //

  final FirebaseFirestore firebase = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final RxBool isActive = false.obs;

  final RxMap userData = {}.obs;
  Future<void> getUserData() async {
    try {
      var snapshot = await firebase
          .collection('moms_kitchens')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      userData.value = snapshot.data() as Map; //snapshot of each doc as map

      editFullNameController.text = userData['ownerName'] ?? '';
      editKitchenNameController.text = userData['kitchenName'] ?? '';
      editAboutCooking.text = userData['description'] ?? '';
      editPhoneNumberController.text = userData['phone'] ?? '';
      editKitchenAddressController.text = userData['kitchenAddress'] ?? '';
      isActive.value = userData['isActive'] ?? false;
      editCuisineController.text = userData['cuisine'] ?? '';
      editSpecialitiesList.value = userData['specialties'] ?? [];
      editPanController.text = userData['panNumber'] ?? '';
      editEmailController.text = userData['email'] ?? '';

      // Load open and close times
      if (userData['openTime'] != null && userData['openTime'] != '') {
        editOpenTime.value = stringToTime(userData['openTime']);
      }
      if (userData['closeTime'] != null && userData['closeTime'] != '') {
        editCloseTime.value = stringToTime(userData['closeTime']);
      }

      log("Got user data: $userData");
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> handleLogin() async {
    //get.snackbar instead of snackbar in scaffoldMessenger, no mount and earlier navigation method in Getx ,title for showing msg at top of the app and msg to display the msg that we want after the action

    // if (emailController.text.isEmpty || passwordController.text.isEmpty) {
    //   Get.snackbar("Error", "Please fill in all fields");
    //   return;
    // }

    isLoading.value =
        true; // setState(() => isLoading = true); instead we use only the variable then .value to get the value

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Get.offAll(() => HomeScreen());
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

  Future<void> registerUser(String googleUid) async {
    if (regPasswordController.text != regConfirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match!');
      return;
    }
    isLoading.value = true;
    try {
      if (googleUid == '') {
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
              "cuisine": regCuisineController.text.trim(),
              "deliveryTime": "",
              "description": regKitchenDesController.text.trim(),
              "featuredDishImage": "",
              "foodPreference": selectedPreference,
              "location": "",
              "priceForOne": '',
              "profileImage": profilePhotoUrl.value,
              'rating': 5,
              'specialties': specialitiesList.toList(),
              'totalOrders': 0,
              "wallet_balance": 0,
              "lifetime_earnings": 0,
              "push_token": "",
              'orderStatus': '',
              "phone": regPhoneController.text,
              "email": regEmailController.text.trim(),
              "kitchenAddress": regKitchenAddress.text.trim(),
              "kitchenName": kitchenNamecontroller.text.trim(),
              "ownerName": nameController.text.trim(),
              "panNumber": regPanNumberController.text.trim(),
              "fssaiNumber": "zsfhhiouiw8854",
              "openTime": openTime.value != null
                  ? "${openTime.value!.hour.toString().padLeft(2, '0')}:${openTime.value!.minute.toString().padLeft(2, '0')}"
                  : "",
              "closeTime": closeTime.value != null
                  ? "${closeTime.value!.hour.toString().padLeft(2, '0')}:${closeTime.value!.minute.toString().padLeft(2, '0')}"
                  : "",
            }); //if we want to auto set or want for specified/fixed/particular document use.set()and set the doc using .doc for adding the Id.
        // .add if we want to create/add on our own, without the need to specify a custom doc Id. ,generates auto id
        //for using the id we used the currentuser part.
      } else {
        final FirebaseFirestore customDB = FirebaseFirestore.instance;
        //to store data data in
        await customDB
            .collection('moms_kitchens')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .set({
              "uid": FirebaseAuth.instance.currentUser?.uid,
              "createdAt":
                  DateTime.now(), //or we can also give time by using Timestamp.now()
              "cuisine": regCuisineController.text.trim(),
              "deliveryTime": "",
              "description": regKitchenDesController.text.trim(),
              "featuredDishImage": "",
              "foodPreference": selectedPreference,
              "location": "",
              "priceForOne": '',
              "profileImage": profilePhotoUrl.value,
              'rating': 5,
              'specialties': specialitiesList.toList(),
              'totalOrders': 0,
              "walletBalance": 0,
              "lifetimeEarnings": 0,
              "pushToken": "",
              'orderStatus': '',
              "phone": regPhoneController.text,
              "email": regEmailController.text.trim(),
              "kitchenAddress": regKitchenAddress.text.trim(),
              "kitchenName": kitchenNamecontroller.text.trim(),
              "ownerName": nameController.text.trim(),
              "panNumber": regPanNumberController.text.trim(),
              "fssaiNumber": "zsfhhiouiw8854",
              "openTime": openTime.value != null
                  ? timeToString(openTime.value!)
                  : "",
              "closeTime": closeTime.value != null
                  ? timeToString(closeTime.value!)
                  : "",
            }); //if we want to auto set or want for specified/fixed/particular document use.set()and set the doc using .doc for adding the Id.
        // .add if we want to create/add on our own, without the need to specify a custom doc Id. ,generates auto id
        //for using the id we used the currentuser part.
      }

      Get.snackbar('Success', 'Account Registered Successfully');
      getUserData();
      Get.off(
        () => HomeScreen(),
      ); //off just like replacement no scope to go back
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'weak-password') message = "The password is too weak.";
      if (e.code == 'email-already-in-use') message = "Email already in use.";

      Get.snackbar('Error', message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signinWithGoogle() async {
    try {
      isLoading.value = true;

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCred = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCred.user!;
      final uid = user.uid;

      final doc = await firebase.collection('moms_kitchens').doc(uid).get();

      if (!doc.exists) {
        nameController.text = user.displayName ?? '';
        regEmailController.text = user.email ?? '';
        regPhoneController.text = user.phoneNumber ?? '';
        profilePhotoUrl.value = user.photoURL ?? '';

        Get.to(() => RegisterScreen(), arguments: uid);
      } else {
        Get.offAll(() => HomeScreen());
      }
    } catch (e) {
      log("Google sign in error: $e");
      Get.snackbar("Error", "Google sign in failed");
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    try {
      await GoogleSignIn().signOut();
      await auth.signOut();
      Get.offAll(() => Login());
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateProfile() async {
    log("updateProfile start ${FirebaseAuth.instance.currentUser?.uid}");
    try {
      await firebase
          .collection('moms_kitchens')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
            "phone": editPhoneNumberController.text,
            "description": editAboutCooking.text.trim(),
            "kitchenAddress": editKitchenAddressController.text.trim(),
            "kitchenName": editKitchenNameController.text.trim(),
            "ownerName": editFullNameController.text.trim(),
            "cuisine": editCuisineController.text.trim(),
            "specialties": editSpecialitiesList.value,
            'panNumber': editPanController.text.trim(),
            'email': editEmailController.text.trim(),
            "openTime": editOpenTime.value != null
                ? timeToString(editOpenTime.value!)
                : "",
            "closeTime": editCloseTime.value != null
                ? timeToString(editCloseTime.value!)
                : "",
          });

      log("updateProfile edit");

      getUserData();
      Get.snackbar('Success', 'Profile Updated');
    } catch (e) {
      log('updateProfile exception: $e');
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

  // Helper method to convert TimeOfDay to 12-hour format string
  String timeToString(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Helper method to parse time string back to TimeOfDay
  TimeOfDay? stringToTime(String timeString) {
    try {
      final parts = timeString.split(' ');
      if (parts.length != 2) return null;

      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;

      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = parts[1];

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }
}
