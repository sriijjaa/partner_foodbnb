import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/home_controller.dart';
import 'package:partner_foodbnb/view/nav_screens/earnings_screen.dart';
import 'package:partner_foodbnb/view/nav_screens/menu_screen.dart';
import 'package:partner_foodbnb/view/nav_screens/orders_screen.dart';
import 'package:partner_foodbnb/view/nav_screens/profile_screen.dart';

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

      body: Obx(() => pages[hc.selectedIndex.value]),//obx used since we have taken the value from rx variable

      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: hc.selectedIndex.value,
          onTap: (index) {
            hc.selectedIndex.value = index;
          },
          backgroundColor: const Color(0xFF16251C),
          selectedItemColor: Colors.red[400],
          unselectedItemColor: Colors.black,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: "Orders",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_sharp),
              label: "Menu",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: "Earnings",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
