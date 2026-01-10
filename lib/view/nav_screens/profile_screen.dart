import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/view/ui_screens/customerhelp_screen.dart';
import 'package:partner_foodbnb/view/ui_screens/edit_profile.dart';
import 'package:partner_foodbnb/view/ui_screens/setting_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final Color primaryRed = Colors.red.shade400;

  final AuthController ac = Get.put(AuthController());
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

            Obx(
              () => Center(
                child: Text(
                  ac.userData.value['name'] ?? "-",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),

            Obx(
              () => Center(
                child: Text(
                  ac.userData.value['ownerName'] ?? "-",
                  style: TextStyle(fontSize: 14),
                ),
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
                  ac.logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
