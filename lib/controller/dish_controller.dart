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
  RxList<String> selectedImagePaths = <String>[].obs; // images for dish
  RxList<String> existingImageUrls =
      <String>[].obs; // existing image URLs when editing

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
        .where('order_status', isEqualTo: 'Pending')
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docs) {
            final orderId = doc.id;

            // Skip if already processed in this session
            if (processedOrderIds.contains(orderId)) continue;

            final orderData = doc.data();
            // Skip if already processed according to Firestore
            if (orderData['_inventory_processed'] == true) {
              processedOrderIds.add(orderId);
              continue;
            }

            log('DEBUG: Processing inventory for order: $orderId');
            processedOrderIds.add(orderId);
            updateDishQuantitiesForOrder(orderData, doc.reference);
          }
        });
  }

  /// Update dish quantities based on order items using a Transaction for atomicity
  Future<void> updateDishQuantitiesForOrder(
    Map<String, dynamic> orderData,
    DocumentReference orderRef,
  ) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final items = orderData['items'] as List<dynamic>?;
      if (items == null || items.isEmpty) return;

      final String orderId = orderData['order_id'] ?? 'Unknown';

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 1. Check the flag INSIDE the transaction
        final orderSnapshot = await transaction.get(orderRef);
        final data = orderSnapshot.data() as Map<String, dynamic>?;

        if (orderSnapshot.exists && data?['_inventory_processed'] == true) {
          log('DEBUG: Transaction aborted, order already processed: $orderId');
          return;
        }

        // 2. Prepare dish updates
        for (var itemData in items) {
          final item = itemData as Map<String, dynamic>;
          final dishName = (item['dish_name'] as String?)?.trim();
          final quantity = (item['quantity'] ?? 1) as int;

          if (dishName == null || dishName.isEmpty) continue;

          final dishQuery = await FirebaseFirestore.instance
              .collection('dish')
              .where('dish_name', isEqualTo: dishName)
              .where('kitchen_id', isEqualTo: currentUserId)
              .limit(1)
              .get();

          if (dishQuery.docs.isNotEmpty) {
            final dishRef = dishQuery.docs.first.reference;
            final dishSnapshot = await transaction.get(dishRef);
            if (dishSnapshot.exists) {
              final currentQty =
                  (dishSnapshot.get('qnt_available') ?? 0) as int;
              final newQty = (currentQty - quantity).clamp(0, currentQty);

              transaction.update(dishRef, {'qnt_available': newQty});
              log(
                'DEBUG: TX - Queued update for $dishName: $currentQty -> $newQty',
              );
            }
          }
        }

        // 3. Mark order as processed
        transaction.update(orderRef, {'_inventory_processed': true});
      });

      log('DEBUG: Transaction successfully committed for order: $orderId');

      Get.snackbar(
        'Inventory Synced',
        'Updated stock for Order #$orderId',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      log('Error in transaction sync: $e');
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

  /// Uploads all currently selected dish images to BunnyCDN and returns their URLs.
  Future<List<String>> uploadDishImages(String dishId) async {
    if (selectedImagePaths.isEmpty) return [];

    List<String> uploadedUrls = [];
    try {
      for (var path in selectedImagePaths) {
        final url = await BunnyCdnService.instance.uploadDishImage(File(path));
        if (url.isNotEmpty) {
          uploadedUrls.add(url);
        }
      }
      return uploadedUrls;
    } catch (e) {
      log('BunnyCDN dish image upload error: $e');
      Get.snackbar(
        'Warning',
        'Some images failed to upload: $e',
        duration: const Duration(seconds: 6),
      );
      return uploadedUrls;
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

      // Upload images first (if selected)
      final List<String> uploadedUrls = await uploadDishImages(id);

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
        "images": uploadedUrls,
        // 'dish_image': imageUrl,
        'ingredients': ingredientsList.toList(),
        'preparation_time': preparationTimeInput.text.trim(),
        'food_rating': 0.0,
        'order_placed': 0,
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
    selectedImagePaths.clear();
    existingImageUrls.clear();
    ingredientsList.clear();
    ingredientInput.clear();
    preparationTimeInput.clear();
  }

  Future<void> updateDish(String id) async {
    try {
      isLoading.value = true;

      // Upload new images if any were selected
      final List<String> newUploadedUrls = await uploadDishImages(id);

      // Combine existing images that were kept with new uploaded ones
      final List<String> allImages = [...existingImageUrls, ...newUploadedUrls];

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

      // Always update images array to reflect removals/additions
      updateData['images'] = allImages;

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
