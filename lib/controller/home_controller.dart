import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/auth_controller.dart';

class HomeController extends GetxController {
  final AuthController ac = Get.put(AuthController());

  Rx selectedIndex = 0.obs;
  

  @override
  void onInit() {
    ac.getUserData();
    super.onInit();
  }
}
