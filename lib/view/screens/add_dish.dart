import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/dish_controller.dart';
import 'package:partner_foodbnb/widgets/bunny_cdn_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddDishScreen extends StatelessWidget {
  AddDishScreen({super.key});

  final DishMenuController dmc = Get.put(DishMenuController());
  final bool isNew = Get.arguments[0]; // to get value from earlier screen
  final String dishId = Get.arguments[1];

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _imagePicker.pickMultiImage();
        if (images.isNotEmpty) {
          final int currentTotal =
              dmc.selectedImagePaths.length + dmc.existingImageUrls.length;
          final int remaining = 5 - currentTotal;
          if (remaining <= 0) {
            Get.snackbar(
              'Limit Reached',
              'You can only upload up to 5 images.',
            );
            return;
          }
          final int toAdd = images.length > remaining
              ? remaining
              : images.length;
          for (int i = 0; i < toAdd; i++) {
            dmc.selectedImagePaths.add(images[i].path);
          }
          if (images.length > remaining) {
            Get.snackbar(
              'Limit Reached',
              'Only $remaining images were added. Total limit is 5.',
            );
          }
        }
      } else {
        final XFile? image = await _imagePicker.pickImage(source: source);
        if (image != null) {
          if (dmc.selectedImagePaths.length + dmc.existingImageUrls.length >=
              5) {
            Get.snackbar(
              'Limit Reached',
              'You can only upload up to 5 images.',
            );
            return;
          }
          dmc.selectedImagePaths.add(image.path);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Widget _buildImageThumbnail({
    required Widget child,
    required VoidCallback onRemove,
    bool isFirst = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 15, top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(width: 110, height: 110, child: child),
          ),
          if (isFirst)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Main",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
            const Text(
              "Dish Name",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: dmc.dishnameController,
              decoration: InputDecoration(
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                hintText: 'Enter dish Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: dmc.dishDescription,
              decoration: InputDecoration(
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                hintText: 'Short Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            const Text(
              "Price",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              controller: dmc.dishPrice,
              decoration: InputDecoration(
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                hintText: 'Enter Price',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
            SizedBox(height: 20),
            const Text(
              "Category",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: dmc.selectedCategory.value.isEmpty
                    ? null
                    : dmc.selectedCategory.value,
                decoration: InputDecoration(
                  hintText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "Mains", child: Text("Mains")),
                  DropdownMenuItem(value: "Starters", child: Text("Starters")),
                  DropdownMenuItem(value: "Desserts", child: Text("Desserts")),
                  DropdownMenuItem(value: "Thali", child: Text("Thali")),
                ],
                onChanged: (value) {
                  dmc.selectedCategory.value = value ?? '';
                  // Reset thali type when switching away from Thali
                  if (value != 'Thali') {
                    dmc.selectedThaliType.value = '';
                  }
                },
              ),
            ),

            // Thali Type — only visible when "Thali" is selected
            Obx(() {
              if (dmc.selectedCategory.value != 'Thali') {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Thali Type",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: dmc.selectedThaliType.value.isEmpty
                        ? null
                        : dmc.selectedThaliType.value,
                    decoration: InputDecoration(
                      hintText: 'Select Thali Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Basic", child: Text("Basic")),
                      DropdownMenuItem(
                        value: "Standard",
                        child: Text("Standard"),
                      ),
                      DropdownMenuItem(
                        value: "Premium",
                        child: Text("Premium"),
                      ),
                    ],
                    onChanged: (value) {
                      dmc.selectedThaliType.value = value ?? '';
                    },
                  ),
                ],
              );
            }),

            //preference
            SizedBox(height: 20),
            const Text(
              "Preference",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: dmc.selectedPreference.value.isEmpty
                    ? null
                    : dmc.selectedPreference.value,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: 'Select Preference',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "Veg", child: Text("Veg")),
                  DropdownMenuItem(value: "Non-Veg", child: Text("Non-Veg")),
                  DropdownMenuItem(value: "Pure-Veg", child: Text("Pure-Veg")),
                ],
                onChanged: (value) {
                  dmc.selectedPreference.value = value ?? '';
                },
              ),
            ),

            const SizedBox(height: 20),

            // Ingredients
            const Text(
              "Ingredients",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dmc.ingredientInput,
                    decoration: InputDecoration(
                      hintText: 'e.g. Tomato, Cheese...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => dmc.addIngredient(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onPressed: dmc.addIngredient,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Obx(
              () => dmc.ingredientsList.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: dmc.ingredientsList
                          .asMap()
                          .entries
                          .map(
                            (e) => Card(
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              color: Colors.grey.shade200,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),

                              // height for the card
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),

                                child: Row(
                                  children: [
                                    const Text(
                                      '• ',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        e.value,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          dmc.ingredientsList.removeAt(e.key),
                                      child: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),

            const SizedBox(height: 20),

            //preparation time
            const Text(
              "Preparation Time",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            TextField(
              controller: dmc.preparationTimeInput,
              decoration: InputDecoration(
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                hintText: 'Enter Preparation Time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            SizedBox(height: 8),

            //quantity available
            const Text(
              "Quantity Available",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (dmc.currentQuantity.value > 0) {
                      dmc.currentQuantity.value--;
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.red[400],
                    ),
                    width: 45,
                    height: 45,

                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  width: 45,
                  height: 45,

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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.red[400],
                    ),
                    width: 45,
                    height: 45,

                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dish Images",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Obx(() {
                  final count =
                      dmc.selectedImagePaths.length +
                      dmc.existingImageUrls.length;
                  return Text(
                    "$count / 5",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: count >= 5 ? Colors.red : Colors.grey.shade600,
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final localImages = dmc.selectedImagePaths;
              final existingImages = dmc.existingImageUrls;
              final totalCount = localImages.length + existingImages.length;

              return SizedBox(
                height: 130, // Increased height for shadows
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // --- Existing Images (Edit mode) ---
                    ...existingImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final url = entry.value;
                      return _buildImageThumbnail(
                        isFirst: index == 0,
                        child: BunnyCdnImage(
                          storageUrl: url,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                        onRemove: () => dmc.existingImageUrls.removeAt(index),
                      );
                    }),

                    // --- Newly Picked Images ---
                    ...localImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final path = entry.value;
                      return _buildImageThumbnail(
                        isFirst: existingImages.isEmpty && index == 0,
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          width: 110,
                          height: 110,
                        ),
                        onRemove: () => dmc.selectedImagePaths.removeAt(index),
                      );
                    }),

                    // --- Add Image Box ---
                    if (totalCount < 5)
                      GestureDetector(
                        onTap: () => _showImagePickerBottomSheet(context),
                        child: Container(
                          width: 110,
                          height: 110,
                          margin: const EdgeInsets.only(top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Colors.red.shade400,
                                size: 30,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Add Image",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // --- Empty Prompt ---
                    if (totalCount == 0)
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                "Click 'Add Image' to upload dish photos",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
            Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: dmc.isLoading.value
                    ? null
                    : () {
                        if (isNew) {
                          dmc.saveDish();
                        } else {
                          dmc.updateDish(dishId);
                        }
                      },
                child: dmc.isLoading.value
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Save Dish",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
