import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/home_controller.dart';
import 'package:partner_foodbnb/view/dashboard/earnings_tab.dart';
import 'package:partner_foodbnb/view/dashboard/menu_tab.dart';
import 'package:partner_foodbnb/view/dashboard/orders_tab.dart';
import 'package:partner_foodbnb/view/dashboard/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> pages = [
    OrderScreen(),
    MenuScreen(),
    EarningsScreen(),
    ProfileScreen(),
  ];

  final HomeController hc = Get.put(HomeController());
  DateTime? lastBackPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // If not on Orders tab (index 0), navigate to Orders tab
        if (hc.selectedIndex.value != 0) {
          hc.selectedIndex.value = 0;
          return;
        }

        // If on Orders tab, implement double-tap to exit
        final now = DateTime.now();
        final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
            lastBackPressed == null ||
            now.difference(lastBackPressed!) > Duration(seconds: 2);

        if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
          lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        // Exit the app
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Obx(() => pages[hc.selectedIndex.value]),
        bottomNavigationBar: Obx(
          () => NavigationBar(
            selectedIndex: hc.selectedIndex.value,
            onDestinationSelected: (index) {
              hc.selectedIndex.value = index;
            },
            backgroundColor: Colors.white,
            indicatorColor: Colors.red.shade400.withAlpha(50),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long, color: Colors.red[400]),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(
                  Icons.menu_book_sharp,
                  color: Colors.red[400],
                ),
                label: 'Menu',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.red[400],
                ),
                label: 'Earnings',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person, color: Colors.red[400]),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
