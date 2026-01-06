import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/view/auth_screens/login.dart';
import 'package:partner_foodbnb/view/ui_screens/customerhelp_screen.dart';
import 'package:partner_foodbnb/view/ui_screens/edit_profile.dart';
import 'package:partner_foodbnb/view/ui_screens/setting_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final Color primaryRed = Colors.red.shade400;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.red,
              child: Icon(Icons.person, size: 40, color: Colors.black),
            ),

            const SizedBox(height: 12),

            const Text(
              "Srija's Kitchen",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 30),

            ListTile(
              leading: const Icon(Icons.edit, color: Colors.black),
              title: const Text(
                "Edit Profile",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Get.to(() => EditProfile());
              },
            ),

            SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.black),
              title: const Text(
                "Settings",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Get.to(() => SettingsScreen());
              },
            ),
            SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.black),
              title: const Text(
                "Customer Support",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Get.to(() => CustomerHelpScreen());
              },
            ),

            SizedBox(
              width: double.infinity,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Get.to(() => Login());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
