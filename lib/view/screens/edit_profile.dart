import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:partner_foodbnb/controller/auth_controller.dart';
import 'package:partner_foodbnb/widgets/bunny_cdn_image.dart';

class EditProfile extends StatelessWidget {
  EditProfile({super.key});

  final AuthController ac = Get.put(AuthController());
  final Color primaryRed = Colors.red.shade400;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        ac.selectedProfileImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  void _showImagePickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Profile Photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.blue.shade600),
                ),
                title: const Text('Take Photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.image, color: Colors.purple.shade600),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // --- Profile Image Section ---
              Center(
                child: Obx(() {
                  final imageUrl = ac.userData['profile_image'];
                  final localPath = ac.selectedProfileImagePath.value;

                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryRed.withAlpha(50),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: localPath.isNotEmpty
                            ? CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.grey[100],
                                backgroundImage: FileImage(File(localPath)),
                              )
                            : CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.grey[100],
                                child:
                                    (imageUrl != null &&
                                        imageUrl.toString().isNotEmpty)
                                    ? ClipOval(
                                        child: BunnyCdnImage(
                                          storageUrl: imageUrl.toString(),
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          placeholder: () => Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey[400],
                                      ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _showImagePickerBottomSheet(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryRed,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(40),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 16),

              Obx(
                () => Center(
                  child: Text(
                    ac.userData.value['kitchen_name']?.toUpperCase() ?? "-",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              Obx(
                () => Center(
                  child: Text(
                    ac.userData.value['owner_name'] ?? "-",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        'Verified Kitchen Partner',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- Section Header: Personal Info ---
              _sectionHeader(Icons.person_outline, 'Personal Information'),
              const SizedBox(height: 12),

              _buildCard([
                _buildFieldLabel('Full Name'),
                _buildTextField(
                  controller: ac.editFullNameController,
                  icon: Icons.person_outline,
                  hint: "Enter your full name",
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('Kitchen Name (Display Name)'),
                _buildTextField(
                  controller: ac.editKitchenNameController,
                  icon: Icons.restaurant_menu,
                  hint: "Enter kitchen name",
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('About Your Cooking'),
                _buildTextField(
                  controller: ac.editAboutCooking,
                  icon: Icons.description_outlined,
                  hint: "Tell customers what makes your food special...",
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('Cuisine'),
                _buildTextField(
                  controller: ac.editCuisineController,
                  icon: Icons.flatware,
                  hint: "e.g. Indian, Chinese, Italian",
                ),
                const SizedBox(height: 24),
                _buildFieldLabel("Specialities"),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: ac.editSpecialityController,
                              icon: Icons.auto_awesome_outlined,
                              hint: "Add a speciality",
                              noPadding: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {
                              if (ac.editSpecialityController.text
                                  .trim()
                                  .isNotEmpty) {
                                ac.editSpecialitiesList.add(
                                  ac.editSpecialityController.text.trim(),
                                );
                                ac.editSpecialityController.clear();
                              }
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryRed,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => ac.editSpecialitiesList.isEmpty
                            ? Text(
                                "No specialities added yet",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: ac.editSpecialitiesList.map((
                                  speciality,
                                ) {
                                  return Chip(
                                    label: Text(speciality),
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    onDeleted: () => ac.editSpecialitiesList
                                        .remove(speciality),
                                    backgroundColor: primaryRed,
                                    visualDensity: VisualDensity.compact,
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('PAN Number'),
                _buildTextField(
                  controller: ac.editPanController,
                  icon: Icons.badge_outlined,
                  hint: "Enter PAN number",
                ),
              ]),

              const SizedBox(height: 32),
              // --- Section Header: Contact Details ---
              _sectionHeader(Icons.contact_phone_outlined, 'Contact Details'),
              const SizedBox(height: 12),
              _buildCard([
                _buildFieldLabel('Phone Number'),
                _buildTextField(
                  controller: ac.editPhoneNumberController,
                  icon: Icons.phone_android,
                  hint: "Enter phone number",
                  keyboardType: TextInputType.phone,
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('Email Address'),
                _buildTextField(
                  controller: ac.editEmailController,
                  icon: Icons.email_outlined,
                  hint: "Enter email address",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('Kitchen Address'),
                _buildTextField(
                  controller: ac.editKitchenAddressController,
                  icon: Icons.location_on_outlined,
                  hint: "e.g. Agartala, Tripura",
                  maxLines: 3,
                ),
              ]),

              const SizedBox(height: 32),
              // --- Section Header: Availability ---
              _sectionHeader(Icons.access_time, 'Availability'),
              const SizedBox(height: 12),
              AvailabilitySection(),

              const SizedBox(height: 44),
              // --- Save Button ---
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: primaryRed.withAlpha(100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: ac.isLoading.value
                        ? null
                        : () => _confirmUpdate(context),
                    child: ac.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Update Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmUpdate(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Update Profile?'),
        content: const Text('Do you want to save the changes to your profile?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Get.back();
              await ac.updateProfile();
            },
            child: const Text(
              'Save Changes',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: primaryRed, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryRed.withAlpha(30), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    bool noPadding = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        prefixIcon: Icon(icon, color: primaryRed.withAlpha(150), size: 20),
        contentPadding: noPadding
            ? null
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryRed, width: 1.5),
        ),
      ),
    );
  }
}

class AvailabilitySection extends StatelessWidget {
  AvailabilitySection({super.key});
  final AuthController ac = Get.find<AuthController>();
  final Color primaryRed = Colors.red.shade400;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryRed.withAlpha(30), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Accepting Orders",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Toggle to open/close your kitchen",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Obx(
                () => Switch.adaptive(
                  activeColor: primaryRed,
                  value: ac.isAcceptingOrders.value,
                  onChanged: (value) => ac.isAcceptingOrders.value = value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Standard Operating Hours'.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TimePickerButton(
                label: "Open Time",
                selectedTime: ac.editOpenTime,
              ),
              const SizedBox(width: 14),
              TimePickerButton(
                label: "Close Time",
                selectedTime: ac.editCloseTime,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TimePickerButton extends StatelessWidget {
  final String label;
  final Rx<TimeOfDay?> selectedTime;
  final AuthController ac = Get.find<AuthController>();

  TimePickerButton({
    super.key,
    required this.label,
    required this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(
        () => GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: selectedTime.value ?? TimeOfDay.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.red.shade400,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              selectedTime.value = picked;
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: selectedTime.value != null
                  ? Colors.red[50]
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedTime.value != null
                    ? Colors.red.shade400
                    : Colors.grey.shade200,
                width: selectedTime.value != null ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: selectedTime.value != null
                        ? Colors.red.shade400
                        : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedTime.value != null
                      ? ac.timeToString(selectedTime.value!)
                      : "Set Time",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: selectedTime.value != null
                        ? Colors.black
                        : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
