
import 'package:artswellfyp/features/authentication/controllers/initialScreenControllers.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/personalization/controllers/userController.dart';

class CustomAppbar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppbar({super.key});

  @override
  State<CustomAppbar> createState() => _CustomAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppbarState extends State<CustomAppbar> {
  // final userController = UserController.instance;
  final List<String> _items = ['EN', 'UR'];
  String? _selectedItem;

  @override
  Widget build(BuildContext context) {
    Get.put(AppLandingController());
    final controller=Get.put(UserController());
    return AppBar(
      backgroundColor: kColorConstants.klPrimaryColor,
      title: const Text('ArtsWell'),
      automaticallyImplyLeading: false,
      leading: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Hero(
          tag: 'loginScreenTag',
          child: IconButton(
            onPressed: () => AppLandingController.instance.homePageNavigation(),
            icon: Image.asset('assets/logo/logo.png', height: 50),
          ),
        ),
      ),
      actions: [
        const SizedBox(width: 2.0),
        GestureDetector(
          onTap: () => AppLandingController.instance.settingsScreenNavigation(),
          child: Obx(() {
            final networkImg = controller.user.value.profilePic;
            final img = networkImg!.isNotEmpty ? NetworkImage(networkImg) : const AssetImage('assets/icons/acct.png');
            return CircleAvatar(
                radius: 50, backgroundImage: img as ImageProvider);
          }),
        ),
      ],
    );
  }
}
