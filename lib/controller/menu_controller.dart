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

  String? selectedCategory;
  Rx isLoading = false.obs;

  RxInt currentQuantity = 0.obs; // for button

  //for menuscreen searchbar
  final TextEditingController searchbar = TextEditingController();
  final RxInt selectedCategoryIndex = 0.obs;

  Future<void> saveDish() async {
    if (dishnameController.text.isEmpty ||
        dishPrice.text.isEmpty ||
        selectedCategory == null) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    isLoading.value = true;

    try {
      // 'Dish' collection data sending to db
      await FirebaseFirestore.instance.collection('Dish').add({
        'name': dishnameController.text.trim(),
        'description': dishDescription.text.trim(),
        'price': int.parse(dishPrice.text.trim()),
        'category': selectedCategory,
        'created_at': DateTime.now(),
        "qnt_available": currentQuantity,
        "restaurant_id": FirebaseAuth.instance.currentUser?.uid,
        "image": [],
      });
      dishnameController.clear();
      dishDescription.clear();
      dishPrice.clear();
      dishQntAvailable.clear();
    } catch (e) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));

      Get.snackbar('Error', 'Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
