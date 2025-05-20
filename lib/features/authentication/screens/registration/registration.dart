import 'package:artswellfyp/features/authentication/controllers/initialScreenControllers.dart';
import 'package:artswellfyp/features/authentication/controllers/loginController.dart';
import 'package:artswellfyp/features/authentication/controllers/registrationController.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/device/deviceComponents.dart';
import 'package:artswellfyp/utils/theme/theme.dart';
import 'package:artswellfyp/utils/validators/validator.dart';
import 'package:flutter/material.dart';
import 'package:artswellfyp/common/styles/registrationformStyling.dart';
import 'package:artswellfyp/common/widgets/textWidgetRegistrationScreen.dart';
import 'package:get/get.dart';

//TODO: This page is for registration screen
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<RegistrationPage> {
  String _userRole = '';
  final controller = Get.put(RegistrationController());

  @override
  Widget build(BuildContext context) {
    final screenHeight = kDeviceComponents.screenHeight(context);
    final screenWidth = kDeviceComponents.screenWidth(context);
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: kColorConstants.klDateTextBottomNavBarSelectedIconColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Hero(
            tag: 'verifyTag',
            child: Image.asset('assets/icons/leftArrow.png'),
          ),
          style: kAppTheme.lightTheme.iconButtonTheme.style?.copyWith(
            backgroundColor: WidgetStatePropertyAll(
                kAppTheme.lightTheme.appBarTheme.backgroundColor
            ),
          ),
          onPressed: () {
            AppLandingController.instance.loginPageNavigation();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            children: [
              // Header Section
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'loginScreenTag',
                      child: Image.asset(
                        'assets/logo/logo.png',
                        height: screenHeight * 0.12, // 12% of screen height
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Don\'t have an account???',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 20 * textScale,
                      ),
                    ),
                    Text(
                      'We\'ve got it covered ;-)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14 * textScale,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Form Title
              Text(
                'Create new account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20 * textScale,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Form Container
              Container(
                constraints: BoxConstraints(
                  minHeight: screenHeight * 0.65,
                  maxWidth: 500, // Max width for tablets
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kColorConstants.klPrimaryColor,
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                ),
                child: Form(
                  key: controller.registrationFormKey,
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Full Name Field
                        FormStylingRegistrationScreen(
                          textEditingController: controller.fullName,
                          validator: (value) =>
                              kValidator.validateEmptyText('UserName', value),
                          img: 'assets/icons/fullName.png',
                          placeholderText: 'Enter Full name',
                          password: false,
                          isNumber: false,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Role Selection
                        Text(
                          'Choose your role',
                          style: TextStyle(
                            fontSize: 14 * textScale,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RoleSelectionButton(
                                role: 'Customer',
                                selectedRole: _userRole,
                                onPressed: () {
                                  setState(() => _userRole = 'Customer');
                                  controller.userType.value = 'Customer';
                                }
                            ),
                            RoleSelectionButton(
                                role: 'Seller',
                                selectedRole: _userRole,
                                onPressed: () {
                                  setState(() => _userRole = 'Seller');
                                  controller.userType.value = 'Seller';
                                }
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Email Field
                        FormStylingRegistrationScreen(
                          validator: (value) => kValidator.validateEmail(value),
                          textEditingController: controller.email,
                          img: 'assets/icons/emailIcon.png',
                          placeholderText: 'Enter your email',
                          password: false,
                          isNumber: false,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Password Field
                        FormStylingRegistrationScreen(
                          textEditingController: controller.password,
                          validator: (value) => kValidator.validatePassword(value),
                          img: 'assets/icons/password.png',
                          placeholderText: 'Enter password',
                          password: true,
                          isNumber: false,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Confirm Password Field
                        FormStylingRegistrationScreen(
                          textEditingController: controller.confirmPassword,
                          img: 'assets/icons/password.png',
                          placeholderText: 'Confirm password',
                          password: true,
                          isNumber: false,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Phone Number Field
                        FormStylingRegistrationScreen(
                          textEditingController: controller.phoneNumber,
                          validator: (value) {
                            if (value == null || value.isEmpty) return null;
                            return kValidator.validatePhoneNumber(value);
                          },
                          img: 'assets/icons/phoneNo.png',
                          placeholderText: 'Enter your Phone Number (Optional)',
                          password: false,
                          isNumber: true,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Terms & Conditions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const textWidgetRegistrationScreen(
                                      text: 'I accept the ',
                                      clr: Colors.white,
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: const textWidgetRegistrationScreen(
                                        text: 'Terms & Conditions',
                                        clr: kColorConstants.klHyperTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Obx(() => Checkbox(
                              value: controller.isTermsAccepted.value,
                              onChanged: (value) {
                                controller.isTermsAccepted.value = value ?? false;
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => RegistrationController.instance.register(),
                            child: Text(
                              'REGISTER',
                              style: TextStyle(
                                fontSize: 16 * textScale,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // OR Divider
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                thickness: 0.7,
                                color: kColorConstants.klDividerColor,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.02),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  fontSize: 14 * textScale,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                thickness: 0.7,
                                color: kColorConstants.klDividerColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Social Login
                        Text(
                          'Sign In with',
                          style: TextStyle(
                            fontSize: 14 * textScale,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        GestureDetector(
                          onTap: () => LoginController().googleSignIn(),
                          child: Image.asset(
                            'assets/icons/googleIcon.png',
                            height: screenHeight * 0.06,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
