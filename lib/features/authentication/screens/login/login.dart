import 'package:artswellfyp/features/authentication/controllers/initialScreenControllers.dart';
import 'package:artswellfyp/features/authentication/screens/login/forgotPassword.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/device/deviceComponents.dart';
import 'package:artswellfyp/utils/validators/validator.dart';
import 'package:flutter/material.dart';
import 'package:artswellfyp/common/styles/loginformStyling.dart';
import 'package:get/get.dart';

import '../../controllers/loginController.dart';

class LoginPage extends StatefulWidget {
  // static AppLandingController get instance => Get.find();
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final screenHeight = kDeviceComponents.screenHeight(context);
    final screenWidth = kDeviceComponents.screenWidth(context);
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: kColorConstants.klDateTextBottomNavBarSelectedIconColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            children: [
              // Logo Section
              SizedBox(height: screenHeight * 0.05),
              Hero(
                tag: 'loginScreenTag',
                child: Center(
                  child: Image.asset(
                    'assets/logo/logo.png',
                    height: screenHeight * 0.15, // 15% of screen height
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Welcome Text
              Text(
                'You were missed...',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 24 * textScale,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Pick up where you left...',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 16 * textScale,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.03),

              // Login Form
              Text(
                'Login to your account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20 * textScale,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              Container(
                constraints: BoxConstraints(
                  minHeight: screenHeight * 0.4,
                  maxWidth: 500, // Maximum form width for tablets
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kColorConstants.klPrimaryColor,
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                ),
                child: Form(
                  key: controller.loginFormKey,
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Email Field
                        FormStyling(
                          controller: controller.emailController,
                          validator: (value) => kValidator.validateEmail(value),
                          img: 'assets/icons/loginIcon.png',
                          placeholderText: 'Enter email/phone number here',
                          password: false,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Password Field
                        FormStyling(
                          controller: controller.passwordController,
                          validator: (value) =>
                              kValidator.validateEmptyText('Password', value),
                          img: 'assets/icons/password.png',
                          placeholderText: 'Enter password',
                          password: true,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Remember Me & Forgot Password Row
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Obx(() => Checkbox(
                                        value: controller.rememberMe.value,
                                        onChanged: (value) =>
                                        controller.rememberMe.value = value!,
                                      )),
                                      Flexible(
                                        child: Text(
                                            'Remember Me',
                                            style: Theme.of(context).textTheme.bodySmall

                                        ),)
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Get.to(
                                    const ForgetPassword(),
                                    transition: Transition.rightToLeftWithFade,
                                  ),
                                  child: Text(
                                      'Forgot Password',
                                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight:FontWeight.w500,fontSize: 12,fontStyle: FontStyle.italic,color: kColorConstants.klHyperTextColor)
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => controller.emailAndPasswordSignIn(),
                            child: Text(
                              'LOGIN',
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
                                color: Colors.grey,
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
                                color: Colors.grey,
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
                          onTap: controller.googleSignIn,
                          child: Image.asset(
                            'assets/icons/googleIcon.png',
                            height: screenHeight * 0.06,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                      ],
                    ),
                  ),
                ),
              ),

              // Registration Prompt
              TextButton(
                onPressed: () =>
                    AppLandingController.instance.registrationPageNavigation(),
                child: Text(
                  'Register here instead',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


