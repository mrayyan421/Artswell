//TODO: class for static products(for testing)
import 'package:artswellfyp/common/widgets/circularContainer.dart';
import 'package:artswellfyp/common/widgets/commonWidgets/roundedImagePromotion.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:artswellfyp/utils/device/deviceComponents.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colorConstants.dart';

class OrderDetailCard extends StatelessWidget {
  const OrderDetailCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      leading: GestureDetector(
        onTap: Get.back,
        child: Image.asset('assets/icons/leftArrow.png'),
      ),
      title: const Text(
        'Order Summary',
        // style: Theme.of(context).textTheme.titleLarge,
      ),
      centerTitle: true,
      backgroundColor: kColorConstants.klPrimaryColor,
    ),
      body: SingleChildScrollView(padding:const EdgeInsets.all(kSizes.mediumPadding),child: Column(
        children: [
          kCircularContainer(padding: const EdgeInsets.all(kSizes.mediumPadding), backgroundColor: kColorConstants.klAntiqueWhiteColor, width: null, showBorder: true, height: null, child: Row(children: [
            Expanded(
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(alignment:Alignment.center,child: RoundedImagePromotion(img: 'assets/images/storeImages/productListing1.jpg', width: kDeviceComponents.screenWidth(context)/2.5, height: kDeviceComponents.screenHeight(context)/2.8, borderRadius: BorderRadius.circular(20),)),
                      Text('Product Name:',style: Theme.of(context).textTheme.headlineMedium),
                      Text('Mud Vase',style: Theme.of(context).textTheme.titleLarge),
                      Text('Product ID:',style: Theme.of(context).textTheme.headlineMedium),
                      Text('AW-007',style: Theme.of(context).textTheme.bodyMedium),
                      Text('Order ID:',style: Theme.of(context).textTheme.headlineMedium),
                      Text('AW-009',style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  Expanded(
                    child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end,
                      children: [//fetch all values from database. create local storage and then proceed 
                        Text('Quantity: x2',style: Theme.of(context).textTheme.labelLarge!.apply(fontStyle: FontStyle.italic)),
                        const SizedBox(height: kSizes.largePadding,),
                        Text('Price',style: Theme.of(context).textTheme.labelLarge,),
                        Text('PKR 130', style: Theme.of(context).textTheme.headlineSmall!.apply(color: kColorConstants.klPrimaryColor)), // To be fetched from db
                        const SizedBox(height: kSizes.xlargePadding,),
                        Text('Total Price',style: Theme.of(context).textTheme.displayLarge,),
                        const SizedBox(height: kSizes.largePadding,),
                        Text('PKR 260', style: Theme.of(context).textTheme.headlineLarge!.apply(fontStyle:FontStyle.italic,color: kColorConstants.klPrimaryColor)), // To be fetched from db
                        Text('Placed on:', style: Theme.of(context).textTheme.labelLarge),
                        Text('01 March 2025', style: Theme.of(context).textTheme.bodyMedium!.apply(fontStyle: FontStyle.italic)), // To be fetched from db
                        ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor: kColorConstants.klHyperTextColor,foregroundColor: Colors.white),onPressed: (){
                          // edit screen logic
                        }, child: const Text('Edit Order'))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],))
        ],
      ),),);
  }
}
