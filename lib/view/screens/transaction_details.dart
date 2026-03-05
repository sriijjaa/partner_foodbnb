import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AllTransactionsPage extends StatelessWidget {
  const AllTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF5350), // Colors.red[400]
        elevation: 0,
        title: const Text(
          'All Transactions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: FirestoreListView(
        padding: const EdgeInsets.all(16),
        query: FirebaseFirestore.instance
            .collection('transactions')
            .where(
              'kitchen_id',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid,
            )
            .orderBy('time', descending: true),
        itemBuilder: (context, doc) {
          final transactionData = doc.data();
          return _buildTransactionCard(context, transactionData);
        },
        emptyBuilder: (context) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No transactions found",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    // Extract and safely convert data
    final DateTime time =
        (data['time'] as Timestamp?)?.toDate() ?? DateTime.now();
    final String status = ((data['status'] ?? 'Pending').toString())
        .toLowerCase();
    final String paymentMode = ((data['payment_mode'] ?? 'COD').toString())
        .toUpperCase();
    final dynamic amountData = data['total_amount'];
    final String amount = amountData != null ? amountData.toString() : '0';

    // Order details
    final String orderId = (data['order_id']?.toString() ?? 'N/A');
    final String txnId = (data['txn_id']?.toString() ?? 'N/A');
    final String dishName = (data['dish_name']?.toString() ?? 'N/A');
    final String kitchenName = (data['kitchen_name']?.toString() ?? 'N/A');
    final String quantity = (data['qnt']?.toString() ?? '1');
    final String userName = (data['user_name']?.toString() ?? 'N/A');
    final String deliveryAddress =
        (data['delivery_address']?.toString() ?? 'N/A');
    final String txnNote = (data['txn_note']?.toString() ?? 'N/A');

    // Determine status color
    final bool isPaid = status.contains('success') || status.contains('paid');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: paymentMode == 'COD'
              ? Colors.orange.withOpacity(0.1)
              : paymentMode == 'UPI'
              ? Colors.blue.withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
          child: Icon(
            isPaid ? Icons.check_circle : Icons.pending_actions,
            color: isPaid ? Colors.green : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          "₹ $amount",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          DateFormat('MMM d, yyyy • hh:mm a').format(time),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPaid
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isPaid ? Colors.green : Colors.orange,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  "Order Details",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _detailRow("Order ID", orderId),
                _detailRow("Transaction ID", txnId),
                _detailRow("Dish", dishName),
                _detailRow("Quantity", quantity),
                _detailRow("Kitchen", kitchenName),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  "Payment Details",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _detailRow("Payment Method", paymentMode),
                _detailRow("Amount", "₹ $amount"),
                _detailRow("Transaction Note", txnNote),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  "Customer Details",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _detailRow("Customer Name", userName),
                _detailRow("Delivery Address", deliveryAddress),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
