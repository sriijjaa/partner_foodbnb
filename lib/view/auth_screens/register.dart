import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/view/auth_screens/login.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final AuthController ac = Get.put(AuthController());

  final String goodleUid = Get.arguments;

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
              textField(
                hint: "Enter your full name",
                icon: Icons.person_outline,
                controller: ac.nameController,
              ),
              const SizedBox(height: 20),
              _label("Restaurant Name"),
              textField(
                hint: "Enter restaurant's full name",
                icon: Icons.restaurant_rounded,
                controller: ac.restaurantNamecontroller,
              ),
              const SizedBox(height: 20),
              _label("Restaurant Description"),
              textField(
                hint: "Enter Restaurant Description",
                icon: Icons.house_outlined,
                controller: ac.regRestaurantDesController,
              ),
              const SizedBox(height: 20),
              _label("Restaurant Address"),
              textField(
                hint: "Enter full Address of Restaurant",
                icon: Icons.maps_home_work_sharp,
                controller: ac.regRestaurantAddress,
              ),

              //food preferences
              const SizedBox(height: 20),

              _label("Food Preference"),
              DropdownButtonFormField<String>(
                initialValue: ac.selectedPreference,
                hint: Text("Select preference"),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                ),
                items: [
                  DropdownMenuItem(value: "Non-veg", child: Text("Non-Veg")),
                  DropdownMenuItem(value: "Veg", child: Text("Veg")),
                  DropdownMenuItem(value: "Pure-veg", child: Text("Pure-veg")),
                ],
                onChanged: (value) {
                  ac.selectedPreference = value;
                },
              ),
              //opentime and close time
              const SizedBox(height: 20),
              _label("Set Cuisine"),
              textField(
                hint: "Enter Your Cuisine",
                icon: Icons.room_service,
                controller: ac.regCuisineController,
              ),

              const SizedBox(height: 20),

              _label("Specialities"),
              // Multi-speciality input with chips
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input field for adding specialities
                  Row(
                    children: [
                      Expanded(
                        child: textField(
                          hint: "Add a speciality",
                          icon: Icons.folder_special,
                          controller: ac.regSpecialityController,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          if (ac.regSpecialityController.text
                              .trim()
                              .isNotEmpty) {
                            ac.specialitiesList.add(
                              ac.regSpecialityController.text.trim(),
                            );
                            ac.regSpecialityController.clear();
                          }
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryRed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Display added specialities as chips
                  Obx(
                    () => ac.specialitiesList.isEmpty
                        ? const Text(
                            "No specialities added yet",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ac.specialitiesList.map((speciality) {
                              return Chip(
                                label: Text(speciality),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  ac.specialitiesList.remove(speciality);
                                },
                                backgroundColor: primaryRed,
                                labelStyle: TextStyle(color: Colors.black),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),

              //pan card number
              const SizedBox(height: 20),
              _label("Pan Number"),
              textField(
                hint: "Pan Number",
                icon: Icons.credit_card,
                controller: ac.regPanNumberController,
              ),

              //fssai number
              // const SizedBox(height: 20),
              // _label("fssai Number"),
              // textField(
              //   hint: "Fssai Number",
              //   icon: Icons.credit_card,
              //   controller: ac.regFssaiNumberController,
              // ),
              const SizedBox(height: 20),
              _label("Email"),
              textField(
                hint: "Enter email",
                icon: Icons.email_outlined,
                controller: ac.regEmailController,
              ),

              const SizedBox(height: 20),
              _label("Enter Phone"),
              textField(
                hint: "Enter your Phone Number",
                icon: Icons.phone,
                controller: ac.regPhoneController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),

              const SizedBox(height: 30),
              _label("Create Password"),
              Obx(
                () => textField(
                  hint: "Create password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: ac.regPasswordController,
                  isVisible: ac.isPasswordVisible.value,
                  onToggleVisibility: () {
                    ac.isPasswordVisible.value = !ac.isPasswordVisible.value;
                  },
                ),
              ),
              const SizedBox(height: 20),

              _label("Confirm Password"),
              textField(
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
                  onPressed: () => ac.registerUser(
                    goodleUid,
                  ), //wont access the value so didnot use .value
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
}

Widget textField({
  required String hint,
  required IconData icon,
  required TextEditingController controller,
  bool isPassword = false,
  VoidCallback? onToggleVisibility,
  bool? isVisible,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextField(
    controller: controller,
    obscureText: isPassword && !(isVisible ?? false),
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      suffixIcon: (isPassword && onToggleVisibility != null)
          ? IconButton(
              icon: Icon(
                (isVisible ?? false) ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: onToggleVisibility,
            )
          : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
    ),
  );
}
