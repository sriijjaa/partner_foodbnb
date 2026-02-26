import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
import 'package:partner_foodbnb/controller/order_controller.dart';

import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/controller/order_dashboard_controller.dart';

class OrderScreen extends StatelessWidget {
  OrderScreen({super.key});

  final OrderController oc = Get.put(OrderController());
  final DashboardController dc = Get.put(DashboardController());
  final AuthController ac = Get.put(AuthController());

  static const _kPrimary = Color(0xFFEF5350); // Red shade 400
  static const _kRadius = 16.0;
  static const _kCardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: _buildAppBar(),
      body: SwipeRefresh.material(
        stateStream: dc.refreshStream,
        onRefresh: dc.refreshData,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          const DashboardStatsCard(),
          const SizedBox(height: 28),
          // ── Recent Orders header with See All ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader('Recent Orders'),
              TextButton.icon(
                onPressed: () => Get.to(() => AllOrdersPage()),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('See All'),
                style: TextButton.styleFrom(
                  foregroundColor: _kPrimary,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where(
                  'kitchen_id',
                  isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              // Sort client-side by created_at descending (newest first)
              final allDocs = snapshot.data!.docs.toList()
                ..sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = aData['created_at'];
                  final bTime = bData['created_at'];
                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  if (aTime is Timestamp && bTime is Timestamp) {
                    return bTime.compareTo(aTime);
                  }
                  return 0;
                });

              // Show only top 5
              final docs = allDocs.take(5).toList();

              return Column(
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final order = Map<String, dynamic>.from(
                        docs[index].data() as Map,
                      );
                      order['docId'] = docs[index].id;
                      return _orderCard(orderData: order);
                    },
                  ),
                  // Show "See All" footer if there are more than 5
                  if (allDocs.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Get.to(() => AllOrdersPage()),
                          icon: const Icon(Icons.list_alt_rounded, size: 18),
                          label: Text(
                            'View all ${allDocs.length} orders',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _kPrimary,
                            side: const BorderSide(
                              color: _kPrimary,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _kPrimary,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Welcome Back! 👋',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: 0.2,
            ),
          ),
          Text(
            'Manage your incoming orders',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Obx(() {
            final isOnline = oc.isActive.value;
            return GestureDetector(
              onTap: () => oc.toggleWithConfirmation(!isOnline),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isOnline
                      ? const Color(0xFF2E7D32) // deep green when open
                      : Colors.white.withOpacity(0.18), // subtle when closed
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.55),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isOnline
                          ? const Color(0xFF2E7D32).withOpacity(0.35)
                          : Colors.black.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: Row(
                    key: ValueKey(isOnline),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOnline
                            ? Icons.storefront_rounded
                            : Icons.store_mall_directory_outlined,
                        color: Colors.white,
                        size: 17,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        isOnline ? 'OPEN' : 'CLOSED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── Section Header ──────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _kPrimary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ─── Dashboard Stats Card ────────────────────────────────────────────────────
  // Removed _dashboardCard method and replaced with DashboardStatsCard StatelessWidget below.

  // ─── Empty & Loading States ──────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_kRadius),
          boxShadow: _kCardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kPrimary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: _kPrimary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Orders Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'New orders from customers will\nappear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: CircularProgressIndicator(color: _kPrimary)),
    );
  }

  // ─── Order Card ──────────────────────────────────────────────────────────────

  /// Formats a Firestore [Timestamp] into e.g. "25 Feb 2026  •  06:32 PM"
  String _formatOrderTime(dynamic rawTimestamp) {
    if (rawTimestamp == null) return '';
    DateTime dt;
    if (rawTimestamp is Timestamp) {
      dt = rawTimestamp.toDate().toLocal();
    } else {
      return '';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $year  •  $hour:$minute $period';
  }

  Widget _orderCard({required Map orderData}) {
    final String status = orderData['order_status'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kRadius),
        boxShadow: _kCardShadow,
        border: Border.all(width: 1, color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(status).withValues(alpha: 0.35),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_kRadius),
                topRight: Radius.circular(_kRadius),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Order ID + status badge ──
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      size: 18,
                      color: _getStatusTextColor(status),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Order #${orderData['order_id'] ?? '—'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _statusBadge(status),
                  ],
                ),
                // ── Order date & time ──
                if (orderData['created_at'] != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: _getStatusTextColor(
                          status,
                        ).withValues(alpha: 0.75),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatOrderTime(orderData['created_at']),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusTextColor(
                            status,
                          ).withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Items ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: (orderData['items'] ?? []).length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = orderData['items'][index];
                return _itemRow(item);
              },
            ),
          ),

          // ── Total Amount ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '₹${orderData['total_amount'] ?? '0'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),

          // ── Order Instructions ──
          if ((orderData['notes'] ?? '').toString().isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE0B2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_rounded,
                    color: Color(0xFFF57F17),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Special Instructions',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          orderData['notes'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF795548),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Delivery Address ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBDEFB)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF1976D2),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderData['delivery_address'] ?? 'No address provided',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1976D2),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Delivery message ──
          Obx(() {
            final message =
                oc.deliveryMessages[orderData['docId']] ??
                orderData['deliveryMessage'];
            final st = orderData['order_status'];

            if (message == null ||
                (st != order_status.delivered &&
                    st != order_status.cancelled)) {
              return const SizedBox();
            }

            final isSuccess = message == 'success';
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSuccess
                      ? Colors.green.shade300
                      : Colors.red.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSuccess
                        ? Icons.check_circle_rounded
                        : Icons.error_rounded,
                    color: isSuccess ? Colors.green : Colors.red,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isSuccess
                          ? 'Yeayyy! 😀 Food delivered successfully'
                          : 'Oh no! ☹️ Food delivery failed',
                      style: TextStyle(
                        color: isSuccess
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // ── Actions ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: _orderActions(orderData),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(Map item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: _kPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['dish_name'] ?? 'Item',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Qty: ${item['quantity'] ?? 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '₹${item['price'] ?? '0'}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Status Helpers ───────────────────────────────────────────────────────────

  Widget _statusBadge(String? status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status ?? 'New',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _getStatusTextColor(status),
        ),
      ),
    );
  }

  Color _getStatusBackgroundColor(String? status) {
    switch (status) {
      case order_status.pending:
        return Colors.blue.shade100;
      case order_status.preparing:
        return Colors.orange.shade100;
      case order_status.inTransit:
        return Colors.purple.shade100;
      case order_status.delivered:
        return Colors.green.shade100;
      case order_status.cancelled:
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status) {
      case order_status.pending:
        return Colors.blue.shade700;
      case order_status.preparing:
        return Colors.orange.shade700;
      case order_status.inTransit:
        return Colors.purple.shade700;
      case order_status.delivered:
        return Colors.green.shade700;
      case order_status.cancelled:
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case order_status.pending:
        return Icons.hourglass_top_rounded;
      case order_status.preparing:
        return Icons.soup_kitchen_rounded;
      case order_status.inTransit:
        return Icons.delivery_dining_rounded;
      case order_status.delivered:
        return Icons.check_circle_rounded;
      case order_status.cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  // ─── Order Actions ────────────────────────────────────────────────────────────

  Widget _orderActions(Map orderData) {
    final String status = orderData['order_status'] ?? '';
    final String docId = orderData['docId'] ?? '';

    if (status == order_status.delivered || status == order_status.cancelled) {
      return const SizedBox();
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _kPrimary,
              side: const BorderSide(color: _kPrimary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              status == order_status.inTransit
                  ? Icons.error_outline_rounded
                  : Icons.close_rounded,
              size: 18,
            ),
            label: Text(
              status == order_status.inTransit ? 'Failed' : 'Reject',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            onPressed: () {
              if (status == order_status.inTransit) {
                oc.failedDelivery(docId);
              } else {
                oc.confirmCancel(docId);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              status == order_status.pending
                  ? Icons.check_rounded
                  : status == order_status.preparing
                  ? Icons.done_all_rounded
                  : Icons.local_shipping_rounded,
              size: 18,
            ),
            label: Text(
              status == order_status.pending
                  ? 'Accept'
                  : status == order_status.preparing
                  ? 'Prepared'
                  : 'Delivered',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            onPressed: () {
              if (status == order_status.pending) {
                oc.acceptOrder(docId);
              } else if (status == order_status.preparing) {
                oc.foodPrepared(docId);
              } else if (status == order_status.inTransit) {
                oc.markDelivered(docId);
              }
            },
          ),
        ),
      ],
    );
  }
}

class order_status {
  static const pending = 'Pending';
  static const preparing = 'Preparing';
  static const inTransit = 'InTransit';
  static const delivered = 'Delivered';
  static const cancelled = 'Cancelled';
}

// ════════════════════════════════════════════════════════════════════════════
// All Orders Page — shows every order sorted by time
// ════════════════════════════════════════════════════════════════════════════

class AllOrdersPage extends StatelessWidget {
  AllOrdersPage({super.key});

  final OrderController oc = Get.find<OrderController>();

  static const _kPrimary = Color(0xFFEF5350);
  static const _kRadius = 16.0;
  static const _kCardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: _kPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'All Orders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where(
              'kitchen_id',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _kPrimary),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _kPrimary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 48,
                      color: _kPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Orders Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort client-side by created_at descending (newest first)
          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aTime = aData['created_at'];
              final bTime = bData['created_at'];
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              if (aTime is Timestamp && bTime is Timestamp) {
                return bTime.compareTo(aTime);
              }
              return 0;
            });

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final order = Map<String, dynamic>.from(
                docs[index].data() as Map,
              );
              order['docId'] = docs[index].id;
              return _orderCard(orderData: order);
            },
          );
        },
      ),
    );
  }

  // ── Helpers (duplicated from OrderScreen so AllOrdersPage is self-contained) ──

  String _formatOrderTime(dynamic rawTimestamp) {
    if (rawTimestamp == null) return '';
    if (rawTimestamp is! Timestamp) return '';
    final dt = rawTimestamp.toDate().toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day $month ${dt.year}  •  $hour:$minute $period';
  }

  Widget _orderCard({required Map orderData}) {
    final String status = orderData['order_status'] ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kRadius),
        boxShadow: _kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(status).withValues(alpha: 0.35),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_kRadius),
                topRight: Radius.circular(_kRadius),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      size: 18,
                      color: _getStatusTextColor(status),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Order #${orderData['order_id'] ?? '—'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _statusBadge(status),
                  ],
                ),
                if (orderData['created_at'] != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: _getStatusTextColor(
                          status,
                        ).withValues(alpha: 0.75),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatOrderTime(orderData['created_at']),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusTextColor(status).withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // ── Items ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: (orderData['items'] ?? []).length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = orderData['items'][index];
                return _itemRow(item);
              },
            ),
          ),
          // ── Order Instructions ──
          if ((orderData['notes'] ?? '').toString().isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE0B2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_rounded,
                    color: Color(0xFFF57F17),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Special Instructions',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          orderData['notes'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF795548),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // ── Delivery message ──
          Obx(() {
            final message =
                oc.deliveryMessages[orderData['docId']] ??
                orderData['deliveryMessage'];
            final st = orderData['order_status'];
            if (message == null ||
                (st != order_status.delivered &&
                    st != order_status.cancelled)) {
              return const SizedBox();
            }
            final isSuccess = message == 'success';
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSuccess
                      ? Colors.green.shade300
                      : Colors.red.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSuccess
                        ? Icons.check_circle_rounded
                        : Icons.error_rounded,
                    color: isSuccess ? Colors.green : Colors.red,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isSuccess
                          ? 'Yeayyy! 😀 Food delivered successfully'
                          : 'Oh no! ☹️ Food delivery failed',
                      style: TextStyle(
                        color: isSuccess
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          // ── Actions ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: _orderActions(orderData),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(Map item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: _kPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['dish_name'] ?? 'Item',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Qty: ${item['quantity'] ?? 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '₹${item['price'] ?? '0'}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String? status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status ?? 'New',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _getStatusTextColor(status),
        ),
      ),
    );
  }

  Color _getStatusBackgroundColor(String? status) {
    switch (status) {
      case order_status.pending:
        return Colors.blue.shade100;
      case order_status.preparing:
        return Colors.orange.shade100;
      case order_status.inTransit:
        return Colors.purple.shade100;
      case order_status.delivered:
        return Colors.green.shade100;
      case order_status.cancelled:
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status) {
      case order_status.pending:
        return Colors.blue.shade700;
      case order_status.preparing:
        return Colors.orange.shade700;
      case order_status.inTransit:
        return Colors.purple.shade700;
      case order_status.delivered:
        return Colors.green.shade700;
      case order_status.cancelled:
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case order_status.pending:
        return Icons.hourglass_top_rounded;
      case order_status.preparing:
        return Icons.soup_kitchen_rounded;
      case order_status.inTransit:
        return Icons.delivery_dining_rounded;
      case order_status.delivered:
        return Icons.check_circle_rounded;
      case order_status.cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Widget _orderActions(Map orderData) {
    final String status = orderData['order_status'] ?? '';
    final String docId = orderData['docId'] ?? '';
    if (status == order_status.delivered || status == order_status.cancelled) {
      return const SizedBox();
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _kPrimary,
              side: const BorderSide(color: _kPrimary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              status == order_status.inTransit
                  ? Icons.error_outline_rounded
                  : Icons.close_rounded,
              size: 18,
            ),
            label: Text(
              status == order_status.inTransit ? 'Failed' : 'Reject',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            onPressed: () {
              if (status == order_status.inTransit) {
                oc.failedDelivery(docId);
              } else {
                oc.confirmCancel(docId);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              status == order_status.pending
                  ? Icons.check_rounded
                  : status == order_status.preparing
                  ? Icons.done_all_rounded
                  : Icons.local_shipping_rounded,
              size: 18,
            ),
            label: Text(
              status == order_status.pending
                  ? 'Accept'
                  : status == order_status.preparing
                  ? 'Prepared'
                  : 'Delivered',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            onPressed: () {
              if (status == order_status.pending) {
                oc.acceptOrder(docId);
              } else if (status == order_status.preparing) {
                oc.foodPrepared(docId);
              } else if (status == order_status.inTransit) {
                oc.markDelivered(docId);
              }
            },
          ),
        ),
      ],
    );
  }
}

class DashboardStatsCard extends StatelessWidget {
  const DashboardStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // GetX controllers
    final DashboardController dc = Get.find<DashboardController>();
    final AuthController ac = Get.find<AuthController>();

    // Extracted constants from OrderScreen
    const kRadius = 16.0;
    const kPrimary = Color(0xFFEF5350);
    const kCardShadow = [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 12,
        spreadRadius: 0,
        offset: Offset(0, 4),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadius),
        boxShadow: kCardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(
            () => _statBox(
              Icons.restaurant_rounded,
              dc.activeDishes.value.toString(),
              'Active\nDishes',
              const Color(0xFF4CAF50),
            ),
          ),
          _verticalDivider(),
          Obx(
            () => _statBox(
              Icons.receipt_long_rounded,
              dc.totalOrders.value.toString(),
              '  New\nOrders',
              kPrimary,
            ),
          ),
          _verticalDivider(),
          Obx(
            () => _statBox(
              Icons.remove_circle_rounded,
              dc.soldOutDishes.value.toString(),
              'Sold Out\n Dishes',
              const Color(0xFFFF9800),
            ),
          ),
          _verticalDivider(),
          Obx(
            () => _statBox(
              Icons.currency_rupee_rounded,
              ac.userData['wallet_balance']?.toString() ?? '0',
              '   Total\nRevenue',
              const Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 48, color: const Color(0xFFEEEEEE));
  }

  Widget _statBox(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9E9E9E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
