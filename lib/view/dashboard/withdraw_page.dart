import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class WithdrawPage extends StatefulWidget {
  final double availableBalance;

  const WithdrawPage({super.key, this.availableBalance = 4250.75});

  @override
  State<WithdrawPage> createState() => WithdrawPageState();
}

class WithdrawPageState extends State<WithdrawPage>
    with SingleTickerProviderStateMixin {
  // Tab controller for UPI / Bank
  late TabController tabController;

  // Theme
  final Color primaryRed = const Color(0xFFEF5350);
  final Color darkText = const Color(0xFF112117);

  // ── UPI form ──────────────────────────────────────────────────────────────
  final upiFormKey = GlobalKey<FormState>();
  final upiIdController = TextEditingController();
  final upiAmountController = TextEditingController();
  String selectedUpiApp = 'Google Pay';
  final List<Map<String, dynamic>> upiApps = [
    {'name': 'Google Pay', 'icon': Icons.g_mobiledata_rounded},
    {'name': 'PhonePe', 'icon': Icons.phone_android},
    {'name': 'Paytm', 'icon': Icons.account_balance_wallet},
    {'name': 'BHIM', 'icon': Icons.currency_rupee},
  ];

  // ── Bank form ─────────────────────────────────────────────────────────────
  final bankFormKey = GlobalKey<FormState>();
  final accHolderController = TextEditingController();
  final accNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final bankNameController = TextEditingController();
  final bankAmountController = TextEditingController();

  // Static recent withdrawals
  final List<Map<String, dynamic>> recentWithdrawals = [
    {
      'method': 'UPI',
      'id': 'partner@upi',
      'amount': 1500.0,
      'status': 'Success',
      'date': '18 Feb 2026',
      'icon': Icons.account_balance_wallet,
    },
    {
      'method': 'Bank',
      'id': 'SBI ••••3456',
      'amount': 2000.0,
      'status': 'Success',
      'date': '10 Feb 2026',
      'icon': Icons.account_balance,
    },
    {
      'method': 'UPI',
      'id': 'partner@upi',
      'amount': 750.0,
      'status': 'Pending',
      'date': '02 Feb 2026',
      'icon': Icons.account_balance_wallet,
    },
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    upiIdController.dispose();
    upiAmountController.dispose();
    accHolderController.dispose();
    accNumberController.dispose();
    ifscController.dispose();
    bankNameController.dispose();
    bankAmountController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void showComingSoon() {
    Get.snackbar(
      '🚀 Feature Coming Soon',
      'Withdrawals will be enabled shortly. Stay tuned!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: darkText,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Please enter an amount';
    final amount = double.tryParse(value);
    if (amount == null) return 'Enter a valid amount';
    if (amount <= 0) return 'Amount must be greater than ₹0';
    if (amount < 100) return 'Minimum withdrawal is ₹100';
    if (amount > widget.availableBalance) {
      return 'Insufficient balance (max ₹${widget.availableBalance.toStringAsFixed(2)})';
    }
    return null;
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: buildAppBar(),
      body: Column(
        children: [
          buildBalanceBanner(),
          buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [buildUpiTab(), buildBankTab()],
            ),
          ),
        ],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: primaryRed,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Withdraw Money',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.red[300], height: 1),
      ),
    );
  }

  // ── Balance Banner ────────────────────────────────────────────────────────
  Widget buildBalanceBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryRed, const Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVAILABLE BALANCE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹ ${widget.availableBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Min. ₹100 • Max. ₹50,000 per request',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────
  Widget buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        labelColor: primaryRed,
        unselectedLabelColor: Colors.grey,
        indicatorColor: primaryRed,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: 'UPI'),
          Tab(
            icon: Icon(Icons.account_balance_outlined),
            text: 'Bank Transfer',
          ),
        ],
      ),
    );
  }

  // ── UPI Tab ───────────────────────────────────────────────────────────────
  Widget buildUpiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: upiFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionLabel('Select UPI App'),
            const SizedBox(height: 10),
            // UPI app selector chips
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: upiApps.map((app) {
                final selected = selectedUpiApp == app['name'];
                return GestureDetector(
                  onTap: () => setState(() => selectedUpiApp = app['name']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? primaryRed.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? primaryRed : Colors.grey[300]!,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: primaryRed.withOpacity(0.15),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          app['icon'] as IconData,
                          color: selected ? primaryRed : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          app['name'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected ? primaryRed : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            sectionLabel('UPI ID'),
            const SizedBox(height: 8),
            buildTextField(
              controller: upiIdController,
              hint: 'e.g. name@upi',
              icon: Icons.alternate_email,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter your UPI ID' : null,
            ),

            const SizedBox(height: 20),
            sectionLabel('Withdrawal Amount (₹)'),
            const SizedBox(height: 8),
            buildTextField(
              controller: upiAmountController,
              hint: 'Enter amount',
              icon: Icons.currency_rupee,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: validateAmount,
              suffix: TextButton(
                onPressed: () {
                  upiAmountController.text = widget.availableBalance
                      .toStringAsFixed(2);
                },
                child: Text(
                  'MAX',
                  style: TextStyle(
                    color: primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            feeNote(),

            const SizedBox(height: 24),
            buildWithdrawButton(
              label: 'Withdraw via UPI',
              icon: Icons.account_balance_wallet,
              onTap: () {
                if (upiFormKey.currentState!.validate()) {
                  showComingSoon();
                }
              },
            ),

            const SizedBox(height: 28),
            buildRecentWithdrawals(),
          ],
        ),
      ),
    );
  }

  // ── Bank Tab ──────────────────────────────────────────────────────────────
  Widget buildBankTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: bankFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionLabel('Account Holder Name'),
            const SizedBox(height: 8),
            buildTextField(
              controller: accHolderController,
              hint: 'Full name as per bank',
              icon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter account holder name' : null,
            ),

            const SizedBox(height: 16),
            sectionLabel('Account Number'),
            const SizedBox(height: 8),
            buildTextField(
              controller: accNumberController,
              hint: 'e.g. 1234567890',
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter account number' : null,
            ),

            const SizedBox(height: 16),
            sectionLabel('IFSC Code'),
            const SizedBox(height: 8),
            buildTextField(
              controller: ifscController,
              hint: 'e.g. SBIN0001234',
              icon: Icons.code,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter IFSC code';
                if (!RegExp(
                  r'^[A-Z]{4}0[A-Z0-9]{6}$',
                ).hasMatch(v.toUpperCase())) {
                  return 'Invalid IFSC format';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),
            sectionLabel('Bank Name'),
            const SizedBox(height: 8),
            buildTextField(
              controller: bankNameController,
              hint: 'e.g. State Bank of India',
              icon: Icons.account_balance_outlined,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter bank name' : null,
            ),

            const SizedBox(height: 16),
            sectionLabel('Withdrawal Amount (₹)'),
            const SizedBox(height: 8),
            buildTextField(
              controller: bankAmountController,
              hint: 'Enter amount',
              icon: Icons.currency_rupee,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: validateAmount,
              suffix: TextButton(
                onPressed: () {
                  bankAmountController.text = widget.availableBalance
                      .toStringAsFixed(2);
                },
                child: Text(
                  'MAX',
                  style: TextStyle(
                    color: primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            feeNote(),

            const SizedBox(height: 24),
            buildWithdrawButton(
              label: 'Withdraw to Bank Account',
              icon: Icons.account_balance,
              onTap: () {
                if (bankFormKey.currentState!.validate()) {
                  showComingSoon();
                }
              },
            ),

            const SizedBox(height: 28),
            buildRecentWithdrawals(),
          ],
        ),
      ),
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────
  Widget sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: darkText,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget feeNote() {
    return Row(
      children: [
        Icon(Icons.info_outline, size: 13, color: Colors.grey[500]),
        const SizedBox(width: 5),
        Text(
          'No withdrawal fees • Processed in 1–3 business days',
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
      ],
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryRed, size: 20),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryRed, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.8),
        ),
      ),
    );
  }

  Widget buildWithdrawButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRecentWithdrawals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionLabel('Recent Withdrawals'),
        const SizedBox(height: 12),
        ...recentWithdrawals.map((w) => recentWithdrawalItem(w)),
      ],
    );
  }

  Widget recentWithdrawalItem(Map<String, dynamic> w) {
    final isSuccess = w['status'] == 'Success';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: primaryRed.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(w['icon'] as IconData, color: primaryRed, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${w['method']}  •  ${w['id']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  w['date'] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '– ₹${(w['amount'] as double).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF112117),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  w['status'] as String,
                  style: TextStyle(
                    color: isSuccess ? Colors.green[700] : Colors.orange[700],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
