import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class DishMenuController extends GetxController {
  //for adding new dish
  final TextEditingController dishnameController = TextEditingController();
  final TextEditingController dishDescription = TextEditingController();
  final TextEditingController dishPrice = TextEditingController();
  final TextEditingController dishQntAvailable = TextEditingController();

  RxString selectedCategory = ''.obs;
  Rx isLoading = false.obs;
  RxInt currentQuantity = 0.obs; // for button
  RxString selectedImagePath = ''.obs; //image for dish

  //for menuscreen searchbar
  final TextEditingController searchbar = TextEditingController();
  final RxInt selectedCategoryIndex = 0.obs;

  Future<void> saveDish() async {
    if (dishnameController.text.isEmpty ||
        dishPrice.text.isEmpty ||
        selectedCategory.value.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    isLoading.value = true;

    try {
      //id for dish
      final String id = DateTime.now().microsecondsSinceEpoch.toString();
      // 'Dish' collection data create/add to db
      await FirebaseFirestore.instance.collection('dish').doc(id).set({
        'name': dishnameController.text.trim(),
        'dish_id': id,
        'description': dishDescription.text.trim(),
        'price': int.parse(dishPrice.text.trim()),
        'category': selectedCategory.value,
        'created_at': DateTime.now(),
        "qnt_available": currentQuantity.value,
        'qnt_total': currentQuantity.value,
        "restaurant_id": FirebaseAuth.instance.currentUser?.uid,
        "image": [],
      });
      clearDishForm();
      Get.snackbar('Added', 'Dish added Successfully');
      Get.back();
    } catch (e) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));

      Get.snackbar('Error', 'Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void clearDishForm() {
    dishnameController.clear();
    dishDescription.clear();
    dishPrice.clear();
    dishQntAvailable.clear();
    selectedCategory.value = '';

    currentQuantity.value = 0;
    selectedImagePath.value = '';
  }

  Future<void> updateDish(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('dish')
          .doc(id)
          .update({
            'dish_id': id,
            'name': dishnameController.text.trim(),
            'description': dishDescription.text.trim(),
            'price': int.parse(dishPrice.text.trim()),
            'category': selectedCategory.value,
            "qnt_available": currentQuantity.value,
            "image": [],
          })
          .then((_) {
            Get.back();
            Get.snackbar('success', 'Dish Edited');
          });
    } catch (e) {
      log('Update Exceptions: $e');
    }
  }
}
