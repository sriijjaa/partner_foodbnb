import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:partner_foodbnb/controller/menu_controller.dart';
import 'package:partner_foodbnb/view/ui_screens/add_dish.dart';

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
    const Color backgroundLight = Colors.white;
    const Color surfaceLight = Color(0xFFF8F8F8);
    final Color primaryRed = Colors.red.shade400;
    const Color textSecondary = Colors.grey;

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, primaryRed),
            _buildSearchBar(surfaceLight, textSecondary),
            _buildCategoryFilters(primaryRed, surfaceLight),

            Expanded(
              child: FirestoreListView(
                query: FirebaseFirestore.instance
                    .collection('Dish')
                    .where(
                      'restaurant_id',
                      isEqualTo: FirebaseAuth
                          .instance
                          .currentUser
                          ?.uid, //ai line ta na dile shob dishes from all shops will come, eta dewa te only current user er dish e show korbe.
                    ), //restuarant filteraltion
                emptyBuilder: (context) => Text('No new Dishes'),
                itemBuilder: (context, doc) {
                  final dishData = doc
                      .data(); //dishData ,local variable e oi particular list ta present thakbe
                  return _buildMenuItem(
                    dishData,
                    surfaceLight,
                    primaryRed,
                    textSecondary,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primary) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Menu",
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => AddDishScreen());
            },
            child: Row(
              children: [
                Icon(Icons.add, color: primary, size: 20),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () {
                    Get.to(() => AddDishScreen());
                  },
                  child: Text(
                    'ADD DISH',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color surface, Color textSec) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        style: const TextStyle(color: Colors.black),
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
          bool isSelected = selectedCategoryIndex.value == index;

          return GestureDetector(
            onTap: () => (() =>
                selectedCategoryIndex.value = index), //dmc why not needed here
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primary : Colors.grey.shade300,
                ),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
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
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
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
                    dish['name'] ?? "N/A",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    dish['description'] ??
                        "-", // if ?? first value is null then it will take second value
                    style: TextStyle(color: textSec, fontSize: 12),
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

            // ---------------- TOGGLE (RIGHT) ----------------
            // Transform.scale(
            //   scale: 0.8,
            //   child: Switch(
            //     value: dish[''],
            //     activeThumbColor: primary,
            //     onChanged: (bool value) {},
            //   ),
            // ),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
