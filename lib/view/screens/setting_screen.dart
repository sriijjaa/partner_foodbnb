import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryRed = Colors.red.shade400;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Home Chef",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "FoodBNB Partner",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _sectionTitle("Account"),
            _settingTile(
              icon: Icons.account_balance,
              title: "Bank Details",
              onTap: () {},
            ),

            _sectionTitle("Preferences"),
            _settingTile(
              icon: Icons.notifications,
              title: "Notifications",
              onTap: () {},
            ),
            _settingTile(
              icon: Icons.language,
              title: "Language",
              subtitle: "English",
              onTap: () {},
            ),

            _sectionTitle("Support"),
            _settingTile(
              icon: Icons.question_answer,
              title: "FAQs",
              onTap: () {},
            ),
            _settingTile(
              icon: Icons.report_problem,
              title: "Raise a Complaint",
              onTap: () {},
            ),
            _settingTile(
              icon: Icons.security,
              title: "Report Safety Issue",
              onTap: () {},
            ),
            _settingTile(
              icon: Icons.support_agent,
              title: "Contact FoodBNB Team",
              onTap: () {},
            ),
            _settingTile(
              icon: Icons.feedback,
              title: "App Feedback",
              onTap: () {},
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // -reusable

  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  static Widget _settingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.red.shade100,
        child: Icon(icon, color: Colors.red),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
