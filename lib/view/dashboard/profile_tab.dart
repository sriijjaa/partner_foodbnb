import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/view/screens/customerhelp_screen.dart';
import 'package:partner_foodbnb/view/screens/edit_profile.dart';
import 'package:partner_foodbnb/view/screens/setting_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthController ac = Get.put(AuthController());

  RxBool isDarkMode = false.obs;
  RxBool isVibration = false.obs;
  RxBool isSound = false.obs;
  RxBool isNotification = false.obs;

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
              child: Stack(
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
            ),
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
            sectionTitle('APP PREFERANCES'),
            Column(
              children: [
                //account
                settingTile(
                  Icons.edit,
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
                //settings
                settingTile(
                  Icons.settings,
                  Colors.grey,
                  'Settings',
                  'Control and Customization',
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  () {
                    Get.to(() => SettingsScreen());
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

                sectionTitle('NOTIFICATIONS'),
                //sound
                settingTile(
                  Icons.volume_up_rounded,
                  Colors.orangeAccent,
                  'Sound',
                  'Notification sounds',
                  Switch(
                    value: isNotification.value,
                    onChanged: (bool value) {
                      isNotification.value = value;
                      Get.snackbar(
                        'Coming Soon',
                        'Push Notification coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  () {},
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
                //vibration
                settingTile(
                  Icons.vibration,
                  Colors.blue,
                  'Vibration',
                  'Haptic Feedback',
                  Switch(
                    value: isVibration.value,
                    onChanged: (bool value) {
                      isVibration.value = value;
                      Get.snackbar(
                        'Coming Soon',
                        'Vibration feature coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  () {},
                ),
                //darkmod
                settingTile(
                  Icons.dark_mode_rounded,
                  Colors.black,
                  'Dark Mode',
                  'Go Dark.',
                  Obx(
                    () => Switch(
                      value: isDarkMode.value,
                      onChanged: (bool value) {
                        isDarkMode.value = value;
                        Get.snackbar(
                          'Coming Soon',
                          'Dark mode feature is under development',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      activeThumbColor: Colors.white, // Thumb color (ON)
                      activeTrackColor: Colors.black, // Track color (ON)
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey,
                    ),
                  ),
                  () {
                    Get.snackbar(
                      'Coming Soon',
                      'Dark mode feature is under development',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
            sectionTitle('DATA & STORAGE'),
            //data saver
            settingTile(
              Icons.vibration,
              Colors.blue,
              'Data Saver Mode',
              'Reduce data usage',
              Switch(
                value: isVibration.value,
                onChanged: (bool value) {
                  isVibration.value = value;
                  Get.snackbar(
                    'Coming Soon',
                    'Vibration feature coming soon',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              () {},
            ),
            //cache
            settingTile(
              Icons.vibration,
              Colors.blue,
              'Clear Cache',
              'Free up storage space',
              Switch(
                value: isVibration.value,
                onChanged: (bool value) {
                  isVibration.value = value;
                  Get.snackbar(
                    'Coming Soon',
                    'Vibration feature coming soon',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              () {},
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
                  title ?? "",
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
}
