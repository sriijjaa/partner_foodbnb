import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/controller/theme_controller.dart';
import 'package:partner_foodbnb/view/screens/customerhelp_screen.dart';
import 'package:partner_foodbnb/view/screens/edit_profile.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthController ac = Get.put(AuthController());

  final ThemeController themeController = Get.put(ThemeController());

  RxBool isVibration = false.obs;
  RxBool isSound = false.obs;
  RxBool isNotification = false.obs;

  final Rx<File?> localProfileImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      localProfileImage.value = File(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Center(
              child: Obx(() {
                final imageUrl = ac.userData['profileImage'];
                log("Profile image: ${ac.userData['profileImage']}");

                return Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.lightBlue[200],
                      backgroundImage:
                          (imageUrl != null && imageUrl.toString().isNotEmpty)
                          ? NetworkImage(imageUrl)
                          : null,
                      child: (imageUrl == null || imageUrl.toString().isEmpty)
                          ? Icon(Icons.person, size: 40, color: Colors.black)
                          : null,
                    ),
                    Positioned(
                      bottom: -10,
                      right: -11,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt_sharp),
                        onPressed: () {
                          // future image picker goes here
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),

            Obx(
              () => Center(
                child: Text(
                  ac.userData.value['kitchenName'] ?? "-",
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
            sectionTitle('APP PREFERANCES'),
            Column(
              children: [
                //account
                settingTile(
                  Icons.edit, //
                  Colors.blue,
                  'Account',
                  'Update your personal Details',
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  () {
                    Get.to(() => EditProfile());
                  },
                ),

                //language
                settingTile(
                  Icons.language,
                  Colors.grey,
                  'Language',
                  'Choose your language',
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  () {},
                ),
                //support
                settingTile(
                  Icons.question_mark_outlined,
                  Colors.pink,

                  'Help & Support',
                  'Navigating Your Needs.',
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  () {
                    Get.to(() => CustomerHelpScreen());
                  },
                ),
                //subsctiption
                settingTile(
                  Icons.local_dining,
                  Colors.amber,
                  'Meal Subscription',
                  'Configure your Preferences.',
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  () {
                    Get.snackbar(
                      'Coming Soon',
                      'This Feature Coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),

                //notification
                settingTile(
                  Icons.notifications_active,
                  Colors.orangeAccent,
                  'Push Notification',
                  'Receive Order Notification',
                  Switch(
                    value: isSound.value,
                    onChanged: (bool value) {
                      isSound.value = value;
                      Get.snackbar(
                        'Coming Soon',
                        'Sound feature coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  () {},
                ),

                //darkmode
                settingTile(
                  Icons.dark_mode_rounded,
                  Colors.black,
                  'Dark Mode',
                  'Go Dark.',
                  Obx(
                    () => Switch(
                      value: themeController.isDarkMode.value,
                      onChanged: themeController.toggleTheme,
                      activeThumbColor: Colors.white,
                      activeTrackColor: Colors.black,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey,
                    ),
                  ),
                  () {},
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
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
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                            ),
                            onPressed: () {
                              Get.back();
                              ac.logout();
                            },
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                'Foodbnb Partner APP 1.0',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'PRIVACY POLICY',
                    style: TextStyle(color: Colors.red[300]),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'TERMS OF SERVICE',
                    style: TextStyle(color: Colors.red[300]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget settingTile(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
    Widget trailing,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? "-",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle ?? "",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Spacer(),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showImagePickerSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Camera"),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Gallery"),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
