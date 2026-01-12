import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/view/auth_screens/login.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final AuthController ac = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    final Color primaryRed = Colors.red.shade400;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Become a ",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: "Foodbnb ",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryRed,
                      ),
                    ),
                    const TextSpan(
                      text: "Chef 👩‍🍳",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Share your home-cooked meals and earn doing what you love.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 36),

              _label("Full Name"),
              _textField(
                hint: "Enter your full name",
                icon: Icons.person_outline,
                controller: ac.nameController,
              ),
              const SizedBox(height: 20),
              _label("Restaurant Name"),
              _textField(
                hint: "Enter restaurant's full name",
                icon: Icons.restaurant_rounded,
                controller: ac.restaurantNamecontroller,
              ),
              const SizedBox(height: 20),
              _label("Restaurant Description"),
              _textField(
                hint: "Enter Restaurant Description",
                icon: Icons.house_outlined,
                controller: ac.regRestaurantDesController,
              ),
              const SizedBox(height: 20),
              _label("Restaurant Address"),
              _textField(
                hint: "Enter full Address of Restaurant",
                icon: Icons.maps_home_work_sharp,
                controller: ac.regRestaurantAddress,
              ),

              const SizedBox(height: 20),

              _label("Email"),
              _textField(
                hint: "Enter email",
                icon: Icons.email_outlined,
                controller: ac.regEmailController,
              ),
              const SizedBox(height: 20),
              _label("Enter Phone"),
              _textField(
                hint: "Enter your Phone Number",
                icon: Icons.phone,

                controller: ac.regPhoneController,
              ),
              const SizedBox(height: 30),

              _label("Create Password"),
              _textField(
                hint: "Create password",
                icon: Icons.lock_outline,
                isPassword: true,
                controller: ac.regPasswordController,
              ),
              const SizedBox(height: 20),

              _label("Confirm Password"),
              _textField(
                hint: "Re-enter password",
                icon: Icons.lock_outline,
                isPassword: true,
                controller: ac.regConfirmPasswordController,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  // to access value use .value
                  onPressed: ac.isLoading.value
                      ? null
                      : ac.registerUser, //wont access the value so didnot use .value
                  child: ac.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Register Now",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: () {
                    Get.to(() => Login());
                  },
                  child: Text(
                    "Already a partner? Log In",
                    style: TextStyle(
                      color: primaryRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Divider(thickness: 2, color: Colors.blueGrey),
                  Text('Or', style: TextStyle(fontWeight: FontWeight.bold)),
                  Divider(),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  ac.signinWithGoogle();
                },
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,

                    children: [
                      Image.asset(
                        'assets/images/google_2.jpg',
                        height: 50,
                        width: 50,
                      ),
                      Text('Sign up with Google'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated helpers to accept controller
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _textField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
