// bindings/organic_product_list_binding.dart
import 'package:get/get.dart';
import '../controllers/organic_product_list_controller.dart';

class OrganicProductListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrganicProductListController>(() => OrganicProductListController());
  }
}