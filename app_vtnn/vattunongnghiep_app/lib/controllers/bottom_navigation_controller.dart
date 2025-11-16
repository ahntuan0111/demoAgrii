import 'package:get/get.dart';

class BottomNaviController extends GetxController{
  var currentIndex = 0.obs;

  void changeTab(int indext){
    currentIndex.value = indext;
  }
}