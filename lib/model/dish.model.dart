import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItemModel {
  final String id;
  final String category;
  final DateTime createdAt;
  final String description;
  final List<String> image;
  final String name;
  final int price;
  final int qntAvailable;
  final int qntTotal;
  final String restaurantId;

  const FoodItemModel({
    required this.id,
    required this.category,
    required this.createdAt,
    required this.description,
    required this.image,
    required this.name,
    required this.price,
    required this.qntAvailable,
    required this.qntTotal,
    required this.restaurantId,
  });

  factory FoodItemModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return FoodItemModel(
      id: doc.id,
      category: data['category'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      image: List<String>.from(data['image'] ?? []),
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      qntAvailable: data['qnt_available'] ?? data['qnt_total'] ?? 0,
      qntTotal: data['qnt_total'] ?? 0,
      restaurantId: data['restaurant_id'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'created_at': Timestamp.fromDate(createdAt),
      'description': description,
      'image': image,
      'name': name,
      'price': price,
      'qnt_available': qntAvailable,
      'qnt_total': qntTotal,
      'restaurant_id': restaurantId,
    };
  }

  FoodItemModel copyWith({
    String? id,
    String? category,
    DateTime? createdAt,
    String? description,
    List<String>? image,
    String? name,
    int? price,
    int? qntAvailable,
    int? qntTotal,
    String? restaurantId,
  }) {
    return FoodItemModel(
      id: id ?? this.id,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      image: image ?? this.image,
      name: name ?? this.name,
      price: price ?? this.price,
      qntAvailable: qntAvailable ?? this.qntAvailable,
      qntTotal: qntTotal ?? this.qntTotal,
      restaurantId: restaurantId ?? this.restaurantId,
    );
  }

  @override
  String toString() {
    return 'FoodItemModel(id: $id, name: $name, price: $price, qntAvailable: $qntAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
