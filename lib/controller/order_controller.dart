import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderStatus {
  static const String pending = 'Pending';
  static const String preparing = 'Preparing';
  static const String inTransit = 'InTransit';
  static const String delivered = 'Delivered';
  static const String cancelled = 'Cancelled';
}

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Kitchen online / offline
  RxBool isActive = false.obs;

  // Track delivery messages for each order
  RxMap<String, String> deliveryMessages = <String, String>{}.obs;

  // Track the selected order type (Orders vs Subscribed)
  RxString selectedOrderType = 'Orders'.obs;

  // ---------------- ONLINE / OFFLINE ----------------

  Future<void> updateIsActive(bool value) async {
    try {
      await _firestore
          .collection('moms_kitchens')
          .doc(auth.currentUser!.uid)
          .update({"isActive": value});

      isActive.value = value;
    } catch (e) {
      log("Update isActive error: $e");
    }
  }

  void toggleWithConfirmation(bool value) {
    if (!value) {
      Get.defaultDialog(
        title: "Go Offline?",
        middleText: "You won’t receive new orders while offline.",
        textConfirm: "Yes",
        textCancel: "Cancel",
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        onConfirm: () {
          updateIsActive(false);
          Get.back();
        },
      );
    } else {
      updateIsActive(true);
    }
  }

  // ---------------- FIRESTORE UPDATE (ONLY ONE) ----------------

  Future<void> updateOrderStatus({
    required String docId,
    required String status,
  }) async {
    try {
      await _firestore.collection('orders').doc(docId).update({
        "order_status": status,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log("Update order status error: $e");
    }
  }

  void confirmCancel(String docId) {
    Get.defaultDialog(
      title: "Cancel Order?",
      middleText: "Are you sure you want to cancel this order?",
      textConfirm: "Yes, Cancel",
      textCancel: "No",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        // Save failure message to Firestore
        await _firestore.collection('orders').doc(docId).update({
          "order_status": OrderStatus.cancelled,
          "updatedAt": FieldValue.serverTimestamp(),
          "deliveryMessage": "failed",
        });
        // Update in-memory state
        deliveryMessages[docId] = 'failed';
        Get.back();
      },
    );
  }

  // ---------------- ORDER ACTIONS ----------------

  // Pending → Preparing
  void acceptOrder(String docId) {
    if (!isActive.value) {
      Get.snackbar(
        "Kitchen Offline",
        "Go online to accept orders",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    updateOrderStatus(docId: docId, status: OrderStatus.preparing);
  }

  // Preparing → InTransit
  void foodPrepared(String docId) {
    updateOrderStatus(docId: docId, status: OrderStatus.inTransit);
  }

  // InTransit → Delivered
  void markDelivered(String docId) async {
    try {
      // Save success message to Firestore
      await _firestore.collection('orders').doc(docId).update({
        "order_status": OrderStatus.delivered,
        "updatedAt": FieldValue.serverTimestamp(),
        "deliveryMessage": "success",
      });
      // Update in-memory state
      deliveryMessages[docId] = 'success';

      // Calculate and update total_revenue in moms_kitchens
      await _updateKitchenTotalRevenue();
    } catch (e) {
      log("markDelivered error: $e");
    }
  }

  // Update kitchen's total_revenue in moms_kitchens collection
  Future<void> _updateKitchenTotalRevenue() async {
    try {
      final kitchenId = auth.currentUser!.uid;

      // Fetch all successfully delivered orders
      final snapshot = await _firestore
          .collection('orders')
          .where('kitchen_id', isEqualTo: kitchenId)
          .where('order_status', isEqualTo: OrderStatus.delivered)
          .get();

      // Calculate total revenue
      double totalRevenue = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final raw = data['total_amount'];
        if (raw != null) {
          totalRevenue += (raw is num)
              ? raw.toDouble()
              : double.tryParse(raw.toString()) ?? 0.0;
        }
      }

      // Update kitchen document with total_revenue
      await _firestore.collection('moms_kitchens').doc(kitchenId).update({
        'total_revenue': totalRevenue,
      });

      log("Kitchen total_revenue updated: $totalRevenue");
    } catch (e) {
      log("_updateKitchenTotalRevenue error: $e");
    }
  }

  // Any stage → Cancelled (with confirmation)
  void failedDelivery(String docId) {
    confirmCancel(docId);
  }

  //when order paid transaction
  Future<void> createTransaction({
    required String uid,
    required double amount,
  }) async {
    final ref = FirebaseFirestore.instance.collection('transactions').doc();

    await ref.set({
      'id': ref.id,
      'uid': uid,
      'amount': amount,
      'type': 'credit',
      'txn_note': 'order',
      'time': DateTime.now(),
    });
  }
}
