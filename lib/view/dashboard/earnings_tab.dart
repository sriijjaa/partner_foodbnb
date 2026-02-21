import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/view/dashboard/withdraw_page.dart';
import 'package:intl/intl.dart';

class EarningsScreen extends StatelessWidget {
  EarningsScreen({super.key});

  // Theme Colors
  final Color primaryRed = const Color(0xFFEF5350); // Colors.red[400]
  final Color textMain = const Color(0xFF112117);

  final AuthController ac = Get.put(AuthController());

  // Reactive filter: 'weekly' | 'lifetime'
  final RxString earningFilter = 'weekly'.obs;
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
                            ac.userData.value['wallet_balance'].toString(),
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
                                    ac.userData.value['wallet_balance']
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
                                  'Ajka Tarik',
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
                                        : ac.userData.value['lifetime_earning']
                                                  ?.toString() ??
                                              '0',
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
                  Expanded(
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
                      child: _buildStatBox(
                        'ORDERS',
                        ac.userData.value['total_orders'].toString(),
                        Icons.shopping_bag,
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
                Text(
                  'See All',
                  style: TextStyle(
                    color: primaryRed,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            FirestoreListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              query: FirebaseFirestore.instance
                  .collection('transactions')
                  .orderBy('time', descending: true),
              itemBuilder: (context, doc) {
                final transactionData = doc.data();

                return Container(
                  decoration: BoxDecoration(
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
                  child: Card(
                    color: Colors.white,
                    // elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ICON
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  transactionData['type'] == 'Card' ||
                                      transactionData['type'] == 'UPI' ||
                                      transactionData['type'] == 'COD'
                                  ? Colors.red.withValues(alpha: 0.12)
                                  : Colors.blue.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              transactionData['type'] == 'credit' &&
                                      transactionData['type'] == 'UPI' &&
                                      transactionData['type'] == 'COD'
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color:
                                  transactionData['type'] == 'credit' ||
                                      transactionData['type'] == 'UPI' ||
                                      transactionData['type'] == 'COD'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "₹ ${transactionData['amount']}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 6),

                                Text(
                                  "Order ID: ${transactionData['order_id']}",
                                  style: TextStyle(fontSize: 13),
                                ),

                                Text(
                                  "Txn ID: ${transactionData['id']}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                SizedBox(height: 6),

                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            transactionData['status'] == 'paid'
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        transactionData['status'].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              transactionData['status'] ==
                                                  'paid'
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 6),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            transactionData['type'] == 'CARD' ||
                                                transactionData['type'] ==
                                                    'UPI' ||
                                                transactionData['type'] == 'COD'
                                            ? Colors.blue.withValues(
                                                alpha: 0.15,
                                              )
                                            : Colors.red.withValues(
                                                alpha: 0.15,
                                              ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        transactionData['type'].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              transactionData['type'] ==
                                                      'CARD' ||
                                                  transactionData['type'] ==
                                                      'UPI' ||
                                                  transactionData['type'] ==
                                                      'COD'
                                              ? Colors.blue
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  transactionData['txn_note'],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            transactionData['time']
                                .toDate()
                                .toString()
                                .substring(0, 16),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },

              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    "Error: $error",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              },
              emptyBuilder: (context) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("No transactions yet"),
                  ],
                );
              },
            ),
          ],
        ),
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
