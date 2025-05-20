import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/size.dart';
import '../../../../utils/validators/validator.dart';
import '../../controllers/forgetPasswordController.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(onPressed: Get.back, icon: Image.asset('assets/icons/leftArrow.png')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kSizes.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dont\'t remember your password?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: kSizes.mediumPadding),
            Text(
              'Let\'s get it fixed...',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: kSizes.mediumPadding * 2),

            /// Text Field
            Form(
              key: controller.forgetPasswordFormKey,
              child: TextFormField(
                controller: controller.email,
                validator: kValidator.validateEmail,
                decoration: InputDecoration(
                  labelText: 'abc@domain.com',labelStyle: Theme.of(context).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w200),
                  prefixIcon: const ImageIcon(color:Colors.black,AssetImage('assets/icons/forgotPassword.png'))
                ),
              ),
            ),
            const SizedBox(height: kSizes.largePadding),

            /// Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.forgetPasswordFormKey.currentState!.validate()) {
                    await controller.sendForgetPasswordEmailForCurrentUser();
                  } else {
                    kLoaders.errorSnackBar(title: 'Incorrect format',message: 'Enter valid email');
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
