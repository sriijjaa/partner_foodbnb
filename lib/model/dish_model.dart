import 'package:cloud_firestore/cloud_firestore.dart';

class DishModel {
  final String dishId;
  final String dishName;
  final String category; //mains, desserts, etc
  final String description;

  final String kitchenId;
  final String kitchenName;
  final List images; // 👈 array of image URLs
  final String preference;
  final List ingredients;
  final double price;
  final int qntAvailable;
  final int qntTotal;
  final String preparationTime;
  final double rating;
  final int ordersCount;
  final String mealCategory;
  final DateTime createdAt;
  final String ownerName;
  final String ownerprofileImage;
  final bool isAvailable;

  DishModel({
    required this.dishId,
    required this.dishName,
    required this.category,
    required this.description,

    required this.kitchenId,
    required this.kitchenName,
    required this.images,
    required this.preference,
    required this.ingredients,

    required this.price,
    required this.qntAvailable,
    required this.qntTotal,

    required this.preparationTime,
    required this.rating,
    required this.ordersCount,
    required this.mealCategory,

    required this.createdAt,
    required this.ownerName,
    required this.ownerprofileImage,
    required this.isAvailable,
  });

  /// Firestore -> Dart
  factory DishModel.fromMap(Map<String, dynamic> map) {
    return DishModel(
      dishId: map['dish_id'] ?? '',
      dishName: map['dish_name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '', //main, starter etc
      kitchenId: map['kitchen_id'] ?? '',
      kitchenName: map['kitchen_name'] ?? 'Unknown',
      images: List<String>.from(map['images'] ?? []), // 👈 image array
      preference: map['preference'] ?? 'N/A',
      ingredients: map['ingredients'] ?? [],
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      qntAvailable: map['qnt_available'] ?? 0,
      qntTotal: map['qnt_total'] ?? 0,
      preparationTime: map['preparation_time'] ?? 'N/A',
      rating: map['rating'] ?? 5,
      ordersCount: map['orders_count'] ?? 0,
      mealCategory:
          map['meal_category'] ??
          'Lunch', // e.g., "Breakfast", "Lunch", "Dinner",
      createdAt: (map['created_at'] as Timestamp).toDate(),
      ownerName: map['owner_name'] ?? 'unknown',
      ownerprofileImage: map['owner_profile_image'] ?? 'unknown',
      isAvailable: map['is_available'] ?? true,
    );
  }

  /// Dart -> Firestore

  Map<String, dynamic> toMap() {
    return {
      'dish_id': dishId,
      'dish_name': dishName,
      'description': description,
      'category': category,

      'kitchen_id': kitchenId,
      'kitchen_name': kitchenName,

      'images': images,

      'preference': preference,
      'ingredients': ingredients,

      'price': price,
      'qnt_available': qntAvailable,
      'qnt_total': qntTotal,

      'preparation_time': preparationTime,
      'rating': rating,
      'orders_count': ordersCount,
      'meal_category': mealCategory,

      'created_at': Timestamp.fromDate(createdAt),

      'owner_name': ownerName,
      'owner_profile_image': ownerprofileImage,

      'is_available': isAvailable,
    };
  }
}
