import 'package:cloud_firestore/cloud_firestore.dart';
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
    final DateTime time = (data['time'] as Timestamp).toDate();
    final String status = (data['status'] ?? 'paid').toString().toLowerCase();
    final String type = (data['type'] ?? 'credit').toString().toUpperCase();

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
          backgroundColor: (type == 'CARD' || type == 'UPI' || type == 'COD')
              ? Colors.red.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
          child: Icon(
            (data['type'] == 'credit' || type == 'UPI' || type == 'COD')
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: (data['type'] == 'credit' || type == 'UPI' || type == 'COD')
                ? Colors.green
                : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          "₹ ${data['amount']}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          DateFormat('MMM d, yyyy • hh:mm a').format(time),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'paid'
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: status == 'paid' ? Colors.green : Colors.red,
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
                _detailRow("Order ID", data['order_id'] ?? 'N/A'),
                _detailRow("Transaction ID", data['id'] ?? 'N/A'),
                _detailRow("Payment Method", type),
                _detailRow("Note", data['txn_note'] ?? 'N/A'),
                const SizedBox(height: 12),

                // Fetching Order details for Username and Address
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('orders')
                      .doc(data['order_id'])
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Text(
                        "Customer details not available",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      );
                    }
                    final orderData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow("Customer Name", orderData['name'] ?? 'N/A'),
                        _detailRow("Address", orderData['address'] ?? 'N/A'),
                        _detailRow("Phone", orderData['phone'] ?? 'N/A'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
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
              value,
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
