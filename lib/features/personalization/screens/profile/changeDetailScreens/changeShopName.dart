import 'package:artswellfyp/common/widgets/customizedShapes/appBar.dart';
import 'package:artswellfyp/features/personalization/controllers/userController.dart';
import 'package:artswellfyp/features/personalization/screens/profile/changeDetailControllers/updateShopNameController.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/validators/validator.dart';

class ChangeShopName extends StatelessWidget {
  const ChangeShopName({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateShopNameController());

    return Scaffold(
      appBar: const CustomAppbar(),

      body: Padding(
        padding: const EdgeInsets.all(kSizes.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings
            Text(
              'Update Shop name',
              style: Theme.of(context).textTheme.labelMedium,
            ),

            const SizedBox(height: kSizes.mediumPadding),
            Form(
              key: controller.updateShopNameFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.shopNameController,
                    validator: (value) => kValidator.validateEmptyText('fullName', value),
                    keyboardType: TextInputType.text,
                    expands: false,
                    decoration: InputDecoration(
                      labelText: UserController.instance.user.value.shopName,
                      prefixIcon: const ImageIcon(AssetImage('assets/icons/fullName.png'),),
                    ),
                  ),

                  const SizedBox(height: kSizes.mediumPadding),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.updateShopName(),
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}