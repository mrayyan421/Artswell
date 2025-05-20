import 'package:artswellfyp/features/personalization/screens/address/addressMain/addNewAddress.dart';
import 'package:artswellfyp/features/shop/models/productModel.dart';
import 'package:artswellfyp/features/shop/screens/productDetails/productDetailScreen/productDetailMain/productDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shop/controllers/productController.dart';

class PersonalizationController extends GetxController{
  static PersonalizationController get instance=> Get.find();
  final addController =PageController();
  var currentIndex=0.obs;

  void updatePageIndicator(int index) {//function to update index
    currentIndex.value = index;
  }
  void userAddAddressNavigation(){
    Get.to(const AddNewAddress(),transition: Transition.downToUp,duration: const Duration(milliseconds: 700),);
  }
  void returnPage(){//previous page navigation
    Get.back();
  }
  /*void deleteDialogueBox(){

  }*/
  void productDetailPageNavigation(BuildContext context,ProductModel product){
    Get.to(ProductDetail(product: product,),binding:BindingsBuilder(()=>Get.put(ProductController())),transition: Transition.downToUp,duration: const Duration(seconds: 1 ),);
  }
}