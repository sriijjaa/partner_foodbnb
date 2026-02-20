import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:partner_foodbnb/controller/dish_controller.dart';
import 'package:partner_foodbnb/view/screens/add_dish.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({super.key});

  final List<String> categories = [
    "All",
    "Active",
    "Sold Out",
    "Starters",
    "Mains",
    "Desserts",
  ];
  final RxInt selectedCategoryIndex = 0.obs;

  final DishMenuController dmc = Get.put(DishMenuController());

  @override
  Widget build(BuildContext context) {
    const Color surfaceLight = Color(0xFFF8F8F8);
    final Color primaryRed = Colors.red.shade400;
    const Color textSecondary = Colors.grey;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Menu Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => AddDishScreen(), arguments: [true, '']);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.red[400], size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'ADD DISH',
                      style: TextStyle(
                        color: Colors.red[400],
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSearchBar(surfaceLight, textSecondary),
              _buildCategoryFilters(primaryRed, surfaceLight),

              Expanded(
                child: Obx(() {
                  String selectedCategory =
                      categories[selectedCategoryIndex.value];

                  return FirestoreListView<Map<String, dynamic>>(
                    query: FirebaseFirestore.instance
                        .collection('dish')
                        .where(
                          'kitchen_id',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                        ),
                    emptyBuilder: (context) =>
                        Center(child: Text('No dishes found')),
                    itemBuilder: (context, doc) {
                      final dishData = doc.data();

                      bool shouldShow = false;

                      if (selectedCategory == "All") {
                        shouldShow = true;
                      } else if (selectedCategory == "Active") {
                        shouldShow = (dishData['qnt_available'] ?? 0) > 0;
                      } else if (selectedCategory == "Sold Out") {
                        shouldShow = (dishData['qnt_available'] ?? 0) == 0;
                      } else if (selectedCategory == "Starters") {
                        shouldShow = dishData['category'] == 'Starters';
                      } else if (selectedCategory == "Mains") {
                        shouldShow = dishData['category'] == 'Mains';
                      } else if (selectedCategory == "Desserts") {
                        shouldShow = dishData['category'] == 'Desserts';
                      }

                      // If item doesn't match filter, don't show it
                      if (!shouldShow) {
                        return const SizedBox.shrink();
                      }

                      // Show item if matches the filter
                      return _buildMenuItem(
                        dishData,
                        surfaceLight,
                        primaryRed,
                        textSecondary,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(Color surface, Color textSec) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
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
        child: TextField(
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "Search menu items...",
            hintStyle: TextStyle(color: textSec),
            prefixIcon: Icon(Icons.search, color: textSec),
            fillColor: surface,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(Color primary, Color surface) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Obx(
            () => GestureDetector(
              onTap: () {
                selectedCategoryIndex.value = index;
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedCategoryIndex.value == index
                      ? primary
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedCategoryIndex.value == index
                        ? primary
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: selectedCategoryIndex.value == index
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(Map dish, Color surface, Color primary, Color textSec) {
    return Opacity(
      opacity: (dish['qnt_available'] > 0) ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              blurRadius: 5,
              spreadRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70,
                height: 70,
                color: Colors.grey.shade200,
                child: Image.asset(
                  'assets/images/placeholder.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.fastfood,
                      color: Colors.grey,
                      size: 32,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish['dish_name'] ?? "N/A",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    dish['description'] ?? "N/A",
                    // if ?? first value is null then it will take second value
                    style: TextStyle(color: textSec, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    dish['preference'] ?? "N/A",
                    style: TextStyle(
                      color: (dish['preference'] == 'Non-Veg')
                          ? Colors.red
                          : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  Text(
                    dish['price'].toString(),
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                Text('Qnt:'),
                Text(
                  dish['qnt_available'].toString(),
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    dmc.dishnameController.text = dish['dish_name'];
                    dmc.dishDescription.text = dish['description'];
                    dmc.dishPrice.text = dish['price'].toString();
                    dmc.selectedCategory.value = dish['category'] ?? '';
                    dmc.currentQuantity.value = dish['qnt_available'];
                    dmc.selectedPreference.value = dish['preference'] ?? '';
                    dmc.ingredientsList.value = List<String>.from(
                      dish['ingredients'] ?? [],
                    );

                    Get.to(
                      () => AddDishScreen(),
                      arguments: [false, dish['dish_id']],
                    ); //no new dish added only edited
                  },
                  icon: Icon(Icons.edit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
