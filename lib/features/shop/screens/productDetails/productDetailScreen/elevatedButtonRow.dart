import 'package:artswellfyp/data/repositories/productRepository/productRepository.dart';
import 'package:artswellfyp/features/shop/screens/cart/cart.dart';
import 'package:artswellfyp/features/shop/screens/store/shopScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../data/repositories/userRepository/userRepository.dart';
import '../../../../../utils/constants/colorConstants.dart';
import '../../../../../utils/constants/size.dart';
import '../../../../personalization/controllers/userController.dart';
import '../../../models/productModel.dart';

class kElevatedButtonRow extends StatelessWidget {
  final ProductModel product;
  kElevatedButtonRow({
    super.key,
    required this.product

  });
  final userCtrl=Get.put(UserController());
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        if(UserController.instance.user.value.role == 'Customer')Expanded(child: ElevatedButton(onPressed: ()=> Get.to(CartScreen(),transition: Transition.downToUp,duration: const Duration(milliseconds:kSizes.initialAnimationTime)),style: ElevatedButton.styleFrom(backgroundColor:kColorConstants.klSearchBarColor,minimumSize: const Size(30, 41),),
            child: const Text('Buy Now'))),
        const SizedBox(width: 10,),
        // if (userCtrl.user.value.role == 'Customer')//change to Customer when backend complete
        Expanded(child: ElevatedButton(onPressed: ()async{
          final shopName = await ShopController().getShopName(product.sellerId);
          Get.to(ShopScreen(sellerId: product.sellerId,shopName: shopName,),transition: Transition.downToUp,duration: const Duration(milliseconds: 700));
        },style: ElevatedButton.styleFrom(backgroundColor:kColorConstants.klVisitStoreElevationBtnClr,minimumSize: const Size(30, 41),), child: const Text('Visit Store',textAlign: TextAlign.center,))),

      ],
    );
  }
}
class ShopController extends GetxController {
  final RxMap<String, String> _shopNames = <String, String>{}.obs;
  final UserRepository _userRepo = UserRepository.instance;

  Future<String> getShopName(String sellerId) async {
    if (_shopNames.containsKey(sellerId)) {
      return _shopNames[sellerId]!;
    }

    try {
      final seller = await ProductRepository.instance.getShopInfo(sellerId);
      _shopNames[sellerId] = seller.shopName ?? 'Shop';
      return _shopNames[sellerId]!;
    } catch (e) {
      return 'Shop';
    }
  }
}