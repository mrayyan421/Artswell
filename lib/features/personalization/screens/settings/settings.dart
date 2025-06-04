import 'package:artswellfyp/common/styles/boxShadow.dart';
import 'package:artswellfyp/common/widgets/commonWidgets/popups/warningPopup.dart';
import 'package:artswellfyp/features/personalization/controllers/userController.dart';
import 'package:artswellfyp/features/personalization/screens/aboutUs/aboutUs.dart';
import 'package:artswellfyp/features/personalization/screens/sellerStory/sellerStoryScreen.dart';
import 'package:artswellfyp/features/shop/controllers/homeController.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:artswellfyp/utils/device/deviceComponents.dart';
import 'package:artswellfyp/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/listTileWidgetSettingsScreen.dart';
import '../../../../common/widgets/commonWidgets/shimmers/shimmerEffect.dart';
import '../../../../data/repositories/authenticationRepository/authenticationRepository.dart';
import '../../controllers/sellerStoryController.dart';
import '../orderManagement.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _locationServicesEnabled = false;

  /*@override
  void initState() {
    // TODO: implement initState
    Get.put(SellerStoryScreen());
  }*/
  @override
  Widget build(BuildContext context) {
    final controller=Get.put(UserController());
    final userController=Get.put(UserController());
    // final sellerStoryController = Get.put(SellerStoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon:
          Image.asset('assets/icons/leftArrow.png'),
        ),
      ),
      backgroundColor: kColorConstants.klPrimaryColor,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: ListTile(
                trailing: GestureDetector(
                  onTap: () {
                    HomeController.instance.editCredentials();
                  }, child: const ImageIcon(AssetImage('assets/icons/edit.png'), color: Colors.white, size: 30,),),
                leading: Hero(tag: 'settingsProfileIconTag', child: Obx(() {
                  final networkImg = userController.user.value.profilePic;
                  final img = networkImg!.isNotEmpty ? NetworkImage(networkImg) : const AssetImage('assets/icons/acct.png');
                  return CircleAvatar(
                      radius: 50, backgroundImage: img as ImageProvider);
                }),),
                title: Obx(() {
                  if(controller.profileLoading.value){
                    return const ShimmerEffect(width: 80, height: 20);
                  }else{
                    return Text(controller.user.value.fullName,style: kAppTheme.lightTheme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold,),);
                  }
                }),
                subtitle: Obx(()=> Text('${controller.user.value.role} Account',style: kAppTheme.lightTheme.textTheme.displaySmall,)), // type should be fetched from firebase firestore
              ),
            ),
            const SizedBox(height: kSizes.smallPadding),
            Center(
              child: SizedBox(
                height: kDeviceComponents.containerHeight(context)*0.68,
                width: kDeviceComponents.containerWidth(context) * 0.75,
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: kColorConstants.klOrangeColor,
                      boxShadow: const [
                        kBoxShadow.verticalBoxShadow,
                      ],
                      borderRadius:
                      BorderRadius.circular(kSizes.largeBorderRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(kSizes.smallPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // SettingsListTileWidget(precedingIcon: 'assets/icons/productManagement.png', title: 'Product Management', subtitle: 'Manage the items purchased',/*onTap: ProductManagement() use getx cntroller*/),
                          SettingsListTileWidget(precedingIcon: 'assets/icons/orderManagement.png', title: 'Order Management', subtitle: 'Manage your orders here',onTap: ()async{
                            // final orderController = Get.put(OrderController());
                            // await orderController.loadUserOrders();
                            Get.to(OrderManagementScreen(),transition: Transition.downToUp,duration: const Duration(milliseconds: 700));}, /*use getx cntroller*/),
                          // SettingsListTileWidget(precedingIcon: 'assets/icons/earning.png', title: 'Earning & Payouts', subtitle: 'Have a look at your store revenue',/*onTap: EarningManagement() use getx cntroller*/),
                          // SettingsListTileWidget(precedingIcon: 'assets/icons/customerManagement.png', title: 'Customer Management', subtitle: 'Manage your customer handlings',/*onTap: ProductManagement() use getx cntroller*/),
                          // SettingsListTileWidget(precedingIcon: 'assets/icons/store.png', title: 'Store Settings', subtitle: 'Update your store settings',/*onTap: ProductManagement() use getx cntroller*/),
                          // SettingsListTileWidget(precedingIcon: 'assets/icons/analytics.png', title: 'Store Analytics', subtitle: 'Monitor your store statistics',),
                          SettingsListTileWidget(precedingIcon: 'assets/icons/help.png', title: 'Support & Help Center', subtitle: 'Contact 24/7 available support',onTap:()=> Get.to(const AboutUsScreen(),transition: Transition.downToUp,duration: const Duration(milliseconds: 700)),),
                          SettingsListTileWidget(precedingIcon: 'assets/icons/location.png', title: 'Location Services', subtitle: 'Enable/Disable Location Services',onTap: HomeController.instance.userAddressNavigation, trailing: Switch(
                              value: _locationServicesEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _locationServicesEnabled = value; //add geolocation api logic here
                                });
                              },
                            ),
                          ),
                          if(UserController.instance.user.value.role=='Seller')SettingsListTileWidget(precedingIcon: 'assets/icons/acct.png', title: 'Seller Story', subtitle: 'Add your experience \& story',onTap: ()=>Get.to(SellerStoryScreen(),transition: Transition.downToUp,duration: const Duration(milliseconds: 700)),),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: kSizes.largePadding),
            ElevatedButton(
              onPressed: (){
                Get.dialog(
                  Warningpopup(warningText:'Are you sure you want to logout?',confirmTxt: 'Logout',onPressed: ()async{
                    await AuthenticationRepository.instance.logout();
                    Get.back();
                  }),
                );},
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
