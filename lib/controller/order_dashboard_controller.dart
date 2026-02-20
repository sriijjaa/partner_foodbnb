import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// COUNTS
  RxInt activeDishes = 0.obs;
  RxInt soldOutDishes = 0.obs;
  RxInt totalOrders = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDishCounts();
    fetchOrderCount();
  }

  /// ACTIVE + SOLD OUT DISHES
  Future<void> fetchDishCounts() async {
    final snapshot = await firestore
        .collection('dish') //Dish -> dish
        .where('kitchen_id', isEqualTo: uid) //Restaurent_id -> kitchen_id
        .get();

    int active = 0;
    int soldOut = 0;

    for (var doc in snapshot.docs) {
      int qty = doc['qnt_available'] ?? 0;

      if (qty > 0) {
        active++;
      } else {
        soldOut++;
      }
    }

    activeDishes.value = active;
    soldOutDishes.value = soldOut;
  }

  /// TOTAL ORDERS
  Future<void> fetchOrderCount() async {
    final snapshot = await firestore
        .collection('orders')
        .where('restaurant_id', isEqualTo: uid)
        .get();

    totalOrders.value = snapshot.docs.length;
  }
}
