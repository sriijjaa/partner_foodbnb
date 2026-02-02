import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/view/dashboard/orders_tab.dart';



class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Kitchen online / offline
  RxBool isActive = false.obs;

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
        "orderStatus": status,
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
      onConfirm: () {
        updateOrderStatus(
          docId: docId,
          status: OrderStatus.cancelled,
        );
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

    updateOrderStatus(
      docId: docId,
      status: OrderStatus.preparing,
    );
  }

  // Preparing → InTransit
  void foodPrepared(String docId) {
    updateOrderStatus(
      docId: docId,
      status: OrderStatus.inTransit,
    );
  }

  // InTransit → Delivered
  void markDelivered(String docId) {
    updateOrderStatus(
      docId: docId,
      status: OrderStatus.delivered,
    );
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
  final ref = FirebaseFirestore.instance
      .collection('transactions')
      .doc();

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
