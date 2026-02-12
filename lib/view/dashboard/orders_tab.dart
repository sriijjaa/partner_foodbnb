import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/order_controller.dart';

import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/controller/order_dashboard_controller.dart';

class OrderScreen extends StatelessWidget {
  OrderScreen({super.key});

  final OrderController oc = Get.put(OrderController()); //for orders
  final DashboardController dc = Get.put(DashboardController());
  final AuthController ac = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    final Color primaryRed = Colors.red.shade400;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        title: Text(
          "Welcome Back!",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Obx(() {
              final isOnline = oc.isActive.value;
              return GestureDetector(
                onTap: () {
                  oc.toggleWithConfirmation(!isOnline);
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 95,
                  height: 36,
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Animated sliding button
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 350),
                        curve: Curves.easeInOutCubic,
                        left: isOnline ? 59 : 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isOnline
                                  ? [Color(0xFF4CAF50), Color(0xFF45a049)]
                                  : [Color(0xFFEF5350), Color(0xFFE53935)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isOnline ? Colors.green : Colors.red)
                                    .withOpacity(0.4),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Text labels
                      // Offline text - positioned to the right of red circle
                      Positioned(
                        left: 36,
                        top: 0,
                        bottom: 0,
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 200),
                          opacity: !isOnline ? 1.0 : 0.0,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Ofline",
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Online text - positioned to the left of green circle
                      Positioned(
                        left: 14,
                        top: 0,
                        bottom: 0,
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 200),
                          opacity: isOnline ? 1.0 : 0.0,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Online",
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _dashboardCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Recents Orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            FirestoreListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              query: FirebaseFirestore.instance
                  .collection('orders')
                  .where(
                    'kitchenId', //restaurant_id ---->>  kitchenId
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                  ),
              emptyBuilder: (context) =>
                  Text('No Orders Available'), //when no items to show
              itemBuilder: (context, doc) {
                final order = doc.data();
                order['docId'] = doc.id;
                return _orderCard(orderData: order);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () => _statBox(
            Icons.restaurant,
            dc.activeDishes.value.toString(),
            "Active",
          ),
        ),

        Obx(
          () => _statBox(
            Icons.receipt_long,
            dc.totalOrders.value.toString(),
            "New",
          ),
        ),

        Obx(
          () => _statBox(
            Icons.remove_circle,
            dc.soldOutDishes.value.toString(),
            "Sold Out",
          ),
        ),

        Obx(
          () => _statBox(
            Icons.currency_rupee,
            ac.userData.value['walletBalance'].toString(),
            "Revenue",
          ),
        ),
      ],
    );
  }

  Widget _statBox(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              blurRadius: 5,
              spreadRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.red.shade400, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard({required Map orderData}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 5,
            spreadRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order ID: ${orderData['order_id']}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(orderData['orderStatus']),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  orderData['orderStatus'] ?? 'New',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStatusTextColor(orderData['orderStatus']),
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: (orderData['items'] ?? []).length,
            itemBuilder: (context, index) {
              var item = orderData['items'][index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: Colors.red.shade400,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] ?? 'Item',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Qty: ${item['quantity'] ?? 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${item['price'] ?? '0'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _orderActions(orderData),

          // Show delivery message if exists
          Obx(() {
            // Check in-memory state first for immediate updates, then Firestore
            final message =
                oc.deliveryMessages[orderData['docId']] ??
                orderData['deliveryMessage'];
            final status = orderData['orderStatus'];

            // Only show message for delivered or cancelled orders
            if (message == null ||
                (status != OrderStatus.delivered &&
                    status != OrderStatus.cancelled)) {
              return const SizedBox();
            }

            return Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message == 'success'
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: message == 'success'
                      ? Colors.green.shade300
                      : Colors.red.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    message == 'success' ? Icons.check_circle : Icons.error,
                    color: message == 'success' ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message == 'success'
                          ? 'yeaaaa !!😀 food has delivered successfully'
                          : 'oh no !! ☹️ the food has been failed to delivered',
                      style: TextStyle(
                        color: message == 'success'
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Buttons
        ],
      ),
    );
  }

  Color _getStatusBackgroundColor(String? status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.blue.shade100;
      case OrderStatus.preparing:
        return Colors.orange.shade100;
      case OrderStatus.inTransit:
        return Colors.purple.shade100;
      case OrderStatus.delivered:
        return Colors.green.shade100;
      case OrderStatus.cancelled:
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.blue.shade700;
      case OrderStatus.preparing:
        return Colors.orange.shade700;
      case OrderStatus.inTransit:
        return Colors.purple.shade700;
      case OrderStatus.delivered:
        return Colors.green.shade700;
      case OrderStatus.cancelled:
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _orderActions(Map orderData) {
    final String status = orderData['orderStatus'];
    final String docId = orderData['docId'];

    if (status == OrderStatus.delivered || status == OrderStatus.cancelled) {
      return const SizedBox();
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              if (status == OrderStatus.inTransit) {
                oc.failedDelivery(docId);
              } else {
                oc.confirmCancel(docId);
              }
            },
            child: Text(
              status == OrderStatus.inTransit ? "Failed to Deliver" : "Reject",
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              if (status == OrderStatus.pending) {
                oc.acceptOrder(docId);
              } else if (status == OrderStatus.preparing) {
                oc.foodPrepared(docId);
              } else if (status == OrderStatus.inTransit) {
                oc.markDelivered(docId);
              }
            },
            child: Text(
              status == OrderStatus.pending
                  ? "Accept"
                  : status == OrderStatus.preparing
                  ? "Food Prepared"
                  : "Marked as Delivered",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class OrderStatus {
  static const pending = "Pending";
  static const preparing = "Preparing";
  static const inTransit = "InTransit";
  static const delivered = "Delivered";
  static const cancelled = "Cancelled";
}
