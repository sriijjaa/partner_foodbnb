import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/home_controller.dart';
import 'package:partner_foodbnb/view/dashboard/earnings_tab.dart';
import 'package:partner_foodbnb/view/dashboard/menu_tab.dart';
import 'package:partner_foodbnb/view/dashboard/orders_tab.dart';
import 'package:partner_foodbnb/view/dashboard/profile_tab.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Widget> pages = [
    OrderScreen(),
    MenuScreen(),
    EarningsScreen(),
    ProfileScreen(),
  ];

  final HomeController hc = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              icon: Icon(Icons.menu_book_sharp),
              selectedIcon: Icon(Icons.menu_book_sharp, color: Colors.red[400]),
              label: 'Menu',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet),
              selectedIcon: Icon(
                Icons.account_balance_wallet,
                color: Colors.red[400],
              ),
              label: 'Earnings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              selectedIcon: Icon(Icons.person, color: Colors.red[400]),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
