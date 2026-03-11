import 'dart:async';
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
  RxString selectedThaliType = ''.obs;
  Rx isLoading = false.obs;
  RxInt currentQuantity = 0.obs; // for button
  RxList<String> ingredientsList = <String>[].obs;
  RxString selectedImagePath = ''.obs; //image for dish
  RxString existingImageUrl = ''.obs; // existing image URL when editing

  //for menuscreen searchbar
  final TextEditingController searchbar = TextEditingController();
  final RxInt selectedCategoryIndex = 0.obs;

  final AuthController ac = Get.put(AuthController());

  // ─── Inventory Sync with Orders ────────────────────────────────────────
  final Set<String> processedOrderIds = {};
  StreamSubscription? orderStreamSubscription;

  /// Initialize order listener to sync inventory with orders
  void initializeOrderListener() {
    startOrderInventorySync();
  }

  /// Listen to orders and automatically update dish quantities
  void startOrderInventorySync() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    // Stop any existing subscription
    orderStreamSubscription?.cancel();

    orderStreamSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('kitchen_id', isEqualTo: currentUserId)
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docs) {
            final orderId = doc.id;

            // Skip if already processed
            if (processedOrderIds.contains(orderId)) continue;

            final orderData = doc.data();
            final status = orderData['order_status'] ?? '';

            // Only process pending orders (freshly placed)
            if (status == 'Pending') {
              processedOrderIds.add(orderId);
              updateDishQuantitiesForOrder(orderData);
            }
          }
        });
  }

  /// Update dish quantities based on order items
  Future<void> updateDishQuantitiesForOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final items = orderData['items'] as List<dynamic>?;
      if (items == null || items.isEmpty) return;

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final batch = FirebaseFirestore.instance.batch();

      for (var itemData in items) {
        final item = itemData as Map<String, dynamic>;
        final dishName = item['dish_name'] as String?;
        final quantity = (item['quantity'] ?? 1) as int;

        if (dishName == null || dishName.isEmpty) continue;

        // Try to find dish by name and kitchen_id
        final querySnapshot = await FirebaseFirestore.instance
            .collection('dish')
            .where('dish_name', isEqualTo: dishName)
            .where('kitchen_id', isEqualTo: currentUserId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final dishDoc = querySnapshot.docs.first;
          final currentQty = (dishDoc['qnt_available'] ?? 0) as int;
          final newQty = (currentQty - quantity).clamp(0, currentQty);

          // Update in batch
          batch.update(dishDoc.reference, {'qnt_available': newQty});
        }
      }

      // Commit all updates
      await batch.commit();

      log('Inventory updated for order: ${orderData['order_id']}');
    } catch (e) {
      log('Error updating dish quantities for order: $e');
    }
  }

  @override
  void onClose() {
    orderStreamSubscription?.cancel();
    super.onClose();
  }

  void addIngredient() {
    final val = ingredientInput.text.trim();
    if (val.isEmpty) return;
    ingredientsList.add(val);
    ingredientInput.clear();
  }

  /// Uploads the currently selected dish image to BunnyCDN and returns its URL.
  /// Returns an empty string if no image is selected.
  Future<String> uploadDishImage(String dishId) async {
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
      final String imageUrl = await uploadDishImage(id);

      // 'Dish' collection data create/add to db
      await FirebaseFirestore.instance.collection('dish').doc(id).set({
        'dish_name': dishnameController.text.trim(),
        'dish_id': id,
        'description': dishDescription.text.trim(),
        'price': int.parse(dishPrice.text.trim()),
        'category': selectedCategory.value,
        'preference': selectedPreference.value,
        'thali_type': selectedCategory.value == 'Thali'
            ? selectedThaliType.value
            : '',
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
    selectedThaliType.value = '';

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
      final String imageUrl = await uploadDishImage(id);

      final Map<String, dynamic> updateData = {
        'dish_id': id,
        'dish_name': dishnameController.text.trim(),
        'description': dishDescription.text.trim(),
        'price': int.parse(dishPrice.text.trim()),
        'category': selectedCategory.value,
        'preference': selectedPreference.value,
        'thali_type': selectedCategory.value == 'Thali'
            ? selectedThaliType.value
            : '',
        "qnt_available": currentQuantity.value,
        'ingredients': ingredientsList.toList(),
        'preparation_time': preparationTimeInput.text.trim(),
      };

      // Only update image fields if a new image was uploaded
      if (imageUrl.isNotEmpty) {
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

  Future<void> deleteDish(String id) async {
    try {
      isLoading.value = true;
      await FirebaseFirestore.instance.collection('dish').doc(id).delete();

      Get.snackbar(
        '🗑️ Dish Deleted',
        'The dish has been removed from your menu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFC62828),
        colorText: Colors.white,
        icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      log('Delete Exception: $e');
      Get.snackbar(
        'Error',
        'Failed to delete dish: ${e.toString()}',
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
