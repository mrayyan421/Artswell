import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artswellfyp/common/widgets/customizedShapes/searchBarContainer.dart';
import '../../../features/shop/controllers/productController.dart';

class KFilter extends StatelessWidget {
  const KFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.put(ProductController());

    return Obx(() {
      return SizedBox(
        width: 120, // Fixed small width
        child: SearchContainer(
          text: _getShortDisplayText(productController.selectedSort.value),
          iconImg: 'assets/icons/fullName.png',
          showBackground: true,
          showBorder: true,
          isSearchable: false,
          onSortSelected: (value) {
            productController.selectedSort.value = value;
            productController.loadProducts();
          }, width: 100,
        ),
      );
    });
  }

  String _getShortDisplayText(String sortValue) {
    switch (sortValue) {
      case 'priceLowToHigh':
        return 'Low-High';
      case 'priceHighToLow':
        return 'High-Low';
      case 'latest':
        return 'Latest';
      default:
        return 'Sort';
    }
  }
}