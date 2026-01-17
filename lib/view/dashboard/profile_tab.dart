import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/view/screens/customerhelp_screen.dart';
import 'package:partner_foodbnb/view/screens/edit_profile.dart';
import 'package:partner_foodbnb/view/screens/setting_screen.dart';

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
            SizedBox(height: 50),
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.person, size: 40, color: Colors.black),
                ),
                Positioned(
                  bottom: -10,
                  right: -11,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.camera_alt_sharp),
                    style: IconButton.styleFrom(shadowColor: Colors.grey),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Obx(
              () => Center(
                child: Text(
                  ac.userData.value['name'] ?? "-",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            Obx(
              () => Center(
                child: Text(
                  ac.userData.value['ownerName'] ?? "-",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),

            settingsTile(Icons.book, 'Account', () {
              Get.to(() => EditProfile());
            }),

            // ListTile(
            //   leading: const Icon(Icons.edit, color: Colors.black),
            //   title: const Text(
            //     "Edit Profile",
            //     style: TextStyle(color: Colors.black),
            //   ),
            //   onTap: () {
            //     Get.to(() => EditProfile());
            //   },
            // ),
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
                  Get.dialog(
                    AlertDialog(
                      title: Text('Logout'),
                      content: Text('Are you sure you want to logout?'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                          ),
                          onPressed: () {
                            Get.back();
                            ac.logout();
                          },
                          child: Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget settingsTile(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.red[400]),
                padding: EdgeInsets.all(2),
                child: Icon(icon),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
