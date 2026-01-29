import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/order_controller.dart';

class OrderScreen extends StatelessWidget {
  OrderScreen({super.key});

  final OrderController oc = Get.put(OrderController()); //for orders

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
              return Row(
                children: [
                  Text(
                    oc.isActive.value ? "Online" : "Offline",
                    style: TextStyle(
                      color: oc.isActive.value ? Colors.green : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: oc.isActive.value,
                    onChanged: (value) {
                      oc.toggleWithConfirmation(value);
                    },
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.green,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade500,
                  ),
                ],
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
                    'restaurant_id',
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
        _statBox(Icons.restaurant, "5", "Active"),
        _statBox(Icons.receipt_long, "3", "New"),
        _statBox(Icons.remove_circle, "2", "Sold Out"),
        _statBox(Icons.currency_rupee, "2300", "Revenue"),
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
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  orderData['orderStatus'] ?? 'New',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
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
                    borderRadius: BorderRadius.circular(8),
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

          // Buttons
        ],
      ),
    );
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
