import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/view/auth_screens/forget_password.dart';
import 'package:partner_foodbnb/view/auth_screens/register.dart'; // Import Firebase

class Login extends StatelessWidget {
  Login({super.key});

  final AuthController ac = Get.put(AuthController());

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final Color primaryRed = Colors.red.shade400;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // LOGO
                Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: primaryRed.withValues(),
                    child: Icon(
                      Icons.restaurant_menu,
                      color: primaryRed,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    "Welcome Back, Chef 👩‍🍳",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),

                _label("Email"),
                _textFormField(
                  hint: "Enter email",
                  icon: Icons.person_outline,
                  controller: ac.emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _label("Password"),
                _textFormField(
                  hint: "Enter password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: ac.passwordController,

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "This field is required";
                    }
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.to(() => ForgetPassword());
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: primaryRed),
                    ),
                  ),
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
                    // onPressed:
                    // ac.isLoading.value
                    //     ? null
                    //     : ac.handleLogin, // Connect to logic
                    onPressed: () {
                      if (ac.isLoading.value) {
                        return;
                      }

                      if (_formKey.currentState!.validate()) {
                        ac.handleLogin();
                      }
                    },
                    child: ac.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Log In",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Divider(thickness: 2, color: Colors.blueGrey),
                    Text('Or', style: TextStyle(fontWeight: FontWeight.bold)),
                    Divider(),
                  ],
                ),
                SizedBox(height: 10),
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

                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Get.to(() => RegisterScreen(), arguments: '');
                    },
                    child: Text(
                      "Don’t have an account? Register as Partner",
                      style: TextStyle(
                        color: primaryRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _textFormField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
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
