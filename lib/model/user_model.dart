import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String address;
  final String email;
  final DateTime joinedAt;
  final int lifetimeEarnings;
  final String name;
  final String pushToken;
  final String kitchenName;
  final String uid;
  final String userType;
  final int walletBalance;

  UserModel({
    required this.address,
    required this.email,
    required this.joinedAt,
    required this.lifetimeEarnings,
    required this.name,
    required this.pushToken,
    required this.kitchenName,
    required this.uid,
    required this.userType,
    required this.walletBalance,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      joinedAt: (map['joined_at'] as Timestamp).toDate(),
      lifetimeEarnings: map['lifetime_earnings'] ?? 0,
      name: map['name'] ?? '',//why name used
      pushToken: map['push_token'] ?? '',
      kitchenName: map['kitchen_name'] ?? '',
      uid: map['uid'] ?? '',
      userType: map['user_type'] ?? '',
      walletBalance: map['wallet_balance'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'email': email,
      'joined_at': Timestamp.fromDate(joinedAt),
      'lifetime_earnings': lifetimeEarnings,
      'name': name,
      'push_token': pushToken,
      'kitchen_name': kitchenName,
      'uid': uid,
      'user_type': userType,
      'wallet_balance': walletBalance,
    };
  }
}
