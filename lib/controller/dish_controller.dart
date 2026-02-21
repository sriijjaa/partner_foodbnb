import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/services/bunny_cdn_service.dart';

class DishMenuController extends GetxController {
  //for adding new dish
  final TextEditingController dishnameController = TextEditingController();
  final TextEditingController dishDescription = TextEditingController();
  final TextEditingController dishPrice = TextEditingController();
  final TextEditingController dishQntAvailable = TextEditingController();
  final TextEditingController ingredientInput = TextEditingController();
  final TextEditingController preparationTimeInput = TextEditingController();

  RxString selectedCategory = ''.obs;
  RxString selectedPreference = ''.obs;
  Rx isLoading = false.obs;
  RxInt currentQuantity = 0.obs; // for button
  RxList<String> ingredientsList = <String>[].obs;
  RxString selectedImagePath = ''.obs; //image for dish
  RxString existingImageUrl = ''.obs; // existing image URL when editing

  //for menuscreen searchbar
  final TextEditingController searchbar = TextEditingController();
  final RxInt selectedCategoryIndex = 0.obs;

  final AuthController ac = Get.put(AuthController());

  void addIngredient() {
    final val = ingredientInput.text.trim();
    if (val.isEmpty) return;
    ingredientsList.add(val);
    ingredientInput.clear();
  }

  /// Uploads the currently selected dish image to BunnyCDN and returns its URL.
  /// Returns an empty string if no image is selected.
  Future<String> _uploadDishImage(String dishId) async {
    if (selectedImagePath.value.isEmpty) return '';

    try {
      final url = await BunnyCdnService.instance.uploadDishImage(
        File(selectedImagePath.value),
      );
      return url;
    } catch (e) {
      log('BunnyCDN dish image upload error: $e');
      Get.snackbar(
        'Warning',
        'Image upload failed: $e',
        duration: const Duration(seconds: 6),
      );
      return '';
    }
  }

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

      // Upload image first (if selected)
      final String imageUrl = await _uploadDishImage(id);

      // 'Dish' collection data create/add to db
      await FirebaseFirestore.instance.collection('dish').doc(id).set({
        'dish_name': dishnameController.text.trim(),
        'dish_id': id,
        'description': dishDescription.text.trim(),
        'price': int.parse(dishPrice.text.trim()),
        'category': selectedCategory.value,
        'preference': selectedPreference.value,
        'created_at': DateTime.now(),
        "qnt_available": currentQuantity.value,
        'qnt_total': currentQuantity.value,
        "kitchen_id": FirebaseAuth.instance.currentUser?.uid,
        "kitchen_name": ac.userData['kitchen_name'] ?? '',
        "images": imageUrl.isNotEmpty ? [imageUrl] : [],
        // 'dish_image': imageUrl,
        'ingredients': ingredientsList.toList(),
        'preparation_time': preparationTimeInput.text.trim(),
      });
      clearDishForm();
      Get.snackbar(
        '🎉 Dish Added!',
        '"${dishnameController.text.trim()}" has been added to your menu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      // Navigate back after the snackbar has had time to show
      await Future.delayed(const Duration(seconds: 2));
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC62828),
        colorText: Colors.white,
        icon: const Icon(Icons.error_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
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
    selectedPreference.value = '';

    currentQuantity.value = 0;
    selectedImagePath.value = '';
    existingImageUrl.value = '';
    ingredientsList.clear();
    ingredientInput.clear();
    preparationTimeInput.clear();
  }

  Future<void> updateDish(String id) async {
    try {
      isLoading.value = true;

      // Upload new image if a new one was selected
      final String imageUrl = await _uploadDishImage(id);

      final Map<String, dynamic> updateData = {
        'dish_id': id,
        'dish_name': dishnameController.text.trim(),
        'description': dishDescription.text.trim(),
        'price': int.parse(dishPrice.text.trim()),
        'category': selectedCategory.value,
        'preference': selectedPreference.value,
        "qnt_available": currentQuantity.value,
        'ingredients': ingredientsList.toList(),
        'preparation_time': preparationTimeInput.text.trim(),
      };

      // Only update image fields if a new image was uploaded
      if (imageUrl.isNotEmpty) {
        // updateData['dish_image'] = imageUrl;
        updateData['images'] = [imageUrl];
      }

      await FirebaseFirestore.instance
          .collection('dish')
          .doc(id)
          .update(updateData)
          .then((_) {
            Get.back();
            Get.snackbar(
              '✅ Dish Updated!',
              'Changes have been saved successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF2E7D32),
              colorText: Colors.white,
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
              duration: const Duration(seconds: 3),
            );
          });
    } catch (e) {
      log('Update Exceptions: $e');
      Get.snackbar(
        'Error',
        'Failed to update dish: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC62828),
        colorText: Colors.white,
        icon: const Icon(Icons.error_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
