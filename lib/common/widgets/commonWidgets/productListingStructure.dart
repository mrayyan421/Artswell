import 'package:artswellfyp/features/shop/controllers/homeController.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:artswellfyp/common/widgets/commonWidgets/roundedImagePromotion.dart';
import 'package:get/get.dart';

class ProductListingStructure extends StatelessWidget {
  const ProductListingStructure({super.key});

  @override
  Widget build(BuildContext context) {
    final controller=Get.put(HomeController());
    return Padding(
      padding: const EdgeInsets.all(kSizes.mediumPadding),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            CarouselSlider(
              items: [
                RoundedImagePromotion(isNetworkImg:false,img: 'assets/images/promotionImages/11.png',width: 400,height: kSizes.promotionImageHeight,borderRadius: BorderRadius.circular(70),),
                RoundedImagePromotion(isNetworkImg:false,img: 'assets/images/promotionImages/22.png',width: 400,height: kSizes.promotionImageHeight,borderRadius: BorderRadius.circular(70)),
                RoundedImagePromotion(isNetworkImg:false,img: 'assets/images/promotionImages/3.png',width: 400,height: kSizes.promotionImageHeight,borderRadius: BorderRadius.circular(70)),
                RoundedImagePromotion(isNetworkImg:false,img: 'assets/images/promotionImages/44.png',width: 400,height: kSizes.promotionImageHeight,borderRadius: BorderRadius.circular(70)),
              ],
              options: CarouselOptions(viewportFraction: 1,onPageChanged:(index,_)=> controller.updatePageIndicator(index)),
            ),
            const SizedBox(height: kSizes.smallestPadding,),
            Obx(()=>Row(mainAxisSize:MainAxisSize.min,children: [for(int i=0;i<4;i++)
              Container(margin: const EdgeInsets.only(right: 10),width: 20,height: 4,decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: controller.currentIndex.value==i? kColorConstants.klPrimaryColor:kColorConstants.klGreyColor,),
              ),],),)
          ],
        ),
      ),
    );
  }
}
