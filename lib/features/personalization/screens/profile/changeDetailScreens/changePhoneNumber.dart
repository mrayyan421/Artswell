import 'package:artswellfyp/common/widgets/customizedShapes/appBar.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/validators/validator.dart';
import '../changeDetailControllers/updateNameController.dart';

class ChangePhoneNumber extends StatelessWidget {
  const ChangePhoneNumber({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateNameController());

    return Scaffold(
      appBar: const CustomAppbar(),

      body: Padding(
        padding: const EdgeInsets.all(kSizes.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings
            Text(
              'Update Phone Number',
              style: Theme.of(context).textTheme.labelMedium,
            ),

            const SizedBox(height: kSizes.mediumPadding),
            Form(
              key: controller.updateUserNameFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.phoneController,
                    validator: (value) => kValidator.validateEmptyText('fullName', value),
                    keyboardType: TextInputType.number,
                    expands: false,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      prefixIcon: ImageIcon(AssetImage('assets/icons/phoneNo.png'),),
                    ),
                  ),

                  const SizedBox(height: kSizes.mediumPadding),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.updateUserName(),
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