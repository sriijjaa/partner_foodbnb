import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/menu_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddDishScreen extends StatelessWidget {
  AddDishScreen({super.key});

  final DishMenuController dmc = Get.put(DishMenuController());

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        dmc.selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  void _showImagePickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
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
    final Color primaryRed = Colors.red.shade400;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        title: const Text("Add Dish", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: dmc.dishnameController,
              decoration: InputDecoration(
                labelText: "Dish Name",
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                hintText: 'Enter dish Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: dmc.dishDescription,
              decoration: InputDecoration(
                labelText: "Description",
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                hintText: 'Short Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 30),
            TextField(
              keyboardType: TextInputType.number,
              controller: dmc.dishPrice,
              decoration: InputDecoration(
                labelText: "Price",
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                hintText: 'Enter Price',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
            SizedBox(height: 30),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: dmc.selectedCategory.value.isEmpty
                    ? null
                    : dmc.selectedCategory.value,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: "Mains", child: Text("Mains")),
                  DropdownMenuItem(value: "Starters", child: Text("Starters")),
                  DropdownMenuItem(value: "Desserts", child: Text("Desserts")),
                ],
                onChanged: (value) {
                  dmc.selectedCategory.value = value ?? '';
                },
              ),
            ),

            const SizedBox(height: 20),
            Text("Quantity Available"),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (dmc.currentQuantity.value > 0) {
                      dmc.currentQuantity.value--;
                    }
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    color: Colors.red[400],
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                ),
                Container(
                  width: 45,
                  height: 45,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: Obx(
                    () => Text(
                      "${dmc.currentQuantity.value} ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    dmc.currentQuantity.value++;
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    color: Colors.red[400],
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                _showImagePickerBottomSheet(context);
              },
              child: Obx(
                () => Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: dmc.selectedImagePath.value.isEmpty
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Upload Dish Image"),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(dmc.selectedImagePath.value),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: dmc.isLoading.value ? null : dmc.saveDish,
              child: dmc.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Save Dish",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
