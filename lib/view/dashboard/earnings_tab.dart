import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/controller/order_dashboard_controller.dart';
import 'package:partner_foodbnb/view/dashboard/withdraw_page.dart';
import 'package:intl/intl.dart';
import 'package:partner_foodbnb/view/screens/transaction_details.dart';

class EarningsScreen extends StatelessWidget {
  EarningsScreen({super.key});

  // Theme Colors
  final Color primaryRed = const Color(0xFFEF5350); // Colors.red[400]
  final Color textMain = const Color(0xFF112117);

  final AuthController ac = Get.put(AuthController());
  final DashboardController dc = Get.find<DashboardController>();

  // Reactive filter: 'weekly' | 'lifetime'
  final RxString earningFilter = 'weekly'.obs;
  final RxString orderFilter = 'successful'.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[400],
        elevation: 0,
        // SpaceBetween used to align back button and title
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Earnings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[100], height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    blurRadius: 5,
                    spreadRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 20,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'AVAILABLE BALANCE',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(
                          () => Text(
                            () {
                              final totalRev =
                                  ac.userData.value['total_revenue'] ?? 0;
                              if (totalRev is num) {
                                return totalRev % 1 == 0
                                    ? totalRev.toInt().toString()
                                    : totalRev.toStringAsFixed(2);
                              }
                              return totalRev.toString();
                            }(),
                            style: TextStyle(
                              color: textMain,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              final balance =
                                  double.tryParse(
                                    (ac.userData.value['total_revenue'] ?? 0)
                                        .toString(),
                                  ) ??
                                  0.0;
                              Get.to(
                                () => WithdrawPage(availableBalance: balance),
                                transition: Transition.rightToLeft,
                              );
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryRed,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.payments,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Get Paid Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom Footer of Card using SpaceBetween
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: primaryRed,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ajka Tarikh',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),

                                Text(
                                  DateFormat(
                                    'EEEE, MMM d',
                                  ).format(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Earning filter toggle ──────────────────────────────
                  Obx(
                    () => Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(25),
                              blurRadius: 5,
                              spreadRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Toggle chips
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                              child: Row(
                                children: [
                                  _filterChip(
                                    label: 'Weekly',
                                    selected: earningFilter.value == 'weekly',
                                    onTap: () => earningFilter.value = 'weekly',
                                  ),
                                  const SizedBox(width: 8),
                                  _filterChip(
                                    label: 'Lifetime',
                                    selected: earningFilter.value == 'lifetime',
                                    onTap: () =>
                                        earningFilter.value = 'lifetime',
                                  ),
                                ],
                              ),
                            ),
                            // Stat value
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        earningFilter.value == 'weekly'
                                            ? Icons.trending_up
                                            : Icons.all_inclusive,
                                        color: primaryRed,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        earningFilter.value == 'weekly'
                                            ? 'THIS WEEK'
                                            : 'LIFETIME',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    earningFilter.value == 'weekly'
                                        ? ac.userData.value['weekly_earning']
                                                  ?.toString() ??
                                              '0'
                                        : () {
                                            final rev = dc.totalRevenue.value;
                                            return rev % 1 == 0
                                                ? rev.toInt().toString()
                                                : rev.toStringAsFixed(2);
                                          }(),
                                    style: TextStyle(
                                      color: textMain,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  //successfull orders and failed orders
                  Obx(
                    () => Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(25),
                              blurRadius: 5,
                              spreadRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Toggle chips
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                              child: Row(
                                children: [
                                  _filterChip(
                                    label: 'Success',
                                    selected: orderFilter.value == 'successful',
                                    onTap: () =>
                                        orderFilter.value = 'successful',
                                  ),
                                  const SizedBox(width: 8),
                                  _filterChip(
                                    label: 'Failed',
                                    selected: orderFilter.value == 'failed',
                                    onTap: () => orderFilter.value = 'failed',
                                  ),
                                ],
                              ),
                            ),
                            // Stat value
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        orderFilter.value == 'successful'
                                            ? Icons.check_circle_outline
                                            : Icons.cancel_outlined,
                                        color: orderFilter.value == 'successful'
                                            ? Colors.green
                                            : primaryRed,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        orderFilter.value == 'successful'
                                            ? 'SUCCESSFUL'
                                            : 'FAILED',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('orders')
                                        .where(
                                          'kitchen_id',
                                          isEqualTo: FirebaseAuth
                                              .instance
                                              .currentUser
                                              ?.uid,
                                        )
                                        .where(
                                          'deliveryMessage',
                                          isEqualTo:
                                              orderFilter.value == 'successful'
                                              ? 'success'
                                              : 'failed',
                                        )
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      final count = snapshot.hasData
                                          ? snapshot.data!.docs.length
                                          : 0;
                                      return Text(
                                        count.toString(),
                                        style: TextStyle(
                                          color:
                                              orderFilter.value == 'successful'
                                              ? Colors.green
                                              : primaryRed,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    color: textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(() => AllTransactionsPage());
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(
                      color: primaryRed,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                //
              ],
            ),
            const SizedBox(height: 12),
            // ── Recent Transactions List ─────────────────────────────
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where(
                    'kitchen_id',
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                  )
                  .orderBy('time', descending: true)
                  .limit(2) //for recent 2 transactions
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("No transactions yet"),
                    ],
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final transactionData =
                        docs[index].data() as Map<String, dynamic>;

                    final DateTime time =
                        (transactionData['time'] as Timestamp?)?.toDate() ??
                        DateTime.now();
                    final String paymentMode =
                        ((transactionData['payment_mode'] ?? 'COD').toString())
                            .toUpperCase();
                    final String status =
                        ((transactionData['status'] ?? 'Pending').toString())
                            .toLowerCase();
                    final dynamic amountData = transactionData['total_amount'];
                    final String amount = amountData != null
                        ? amountData.toString()
                        : '0';

                    // Extract details
                    final String orderId =
                        (transactionData['order_id']?.toString() ?? 'N/A');
                    final String txnId =
                        (transactionData['txn_id']?.toString() ?? 'N/A');
                    final String dishName =
                        (transactionData['dish_name']?.toString() ?? 'N/A');
                    final String kitchenName =
                        (transactionData['kitchen_name']?.toString() ?? 'N/A');
                    final String quantity =
                        (transactionData['qnt']?.toString() ?? '1');
                    final String userName =
                        (transactionData['user_name']?.toString() ?? 'N/A');
                    final String deliveryAddress =
                        (transactionData['delivery_address']?.toString() ??
                        'N/A');
                    final String txnNote =
                        (transactionData['txn_note']?.toString() ?? 'N/A');

                    final bool isPaid =
                        status.contains('success') || status.contains('paid');

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
                        shape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                        ),
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('MMM d, yyyy • hh:mm a').format(time),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
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
                  },
                );
              },
            ),
          ],
        ),
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
            width: 110,
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

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? primaryRed : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryRed, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: textMain,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
