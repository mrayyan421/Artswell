import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/addressController.dart';
import '../addressCard.dart';
import 'addNewAddress.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addressController = Get.put(AddressController());

    return Scaffold(
      appBar: AppBar(
        title: Text('My Addresses',style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),),
        leading: GestureDetector(onTap: Get.back,child: const ImageIcon(AssetImage('assets/icons/leftArrow.png')),),
      ),
      body: Obx(() {
        if (addressController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (addressController.addresses.isEmpty) {
          return const Center(child: Text('No addresses found. Add your first address!'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: addressController.addresses.length,
          itemBuilder: (context, index) {
            final address = addressController.addresses[index];
            return kAddressContainer(
              address: address,
              selectedAddress: address.isDefault,
              // selectedAddress: addressController.selectedAddress.value?.id == address.id,
              onTap: ()async => addressController.setDefaultAddress(address.id),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(child:const ImageIcon(AssetImage('assets/icons/add.png')),onPressed: () => Get.to(() => const AddNewAddress(),transition: Transition.downToUp,duration: const Duration(milliseconds: 800))),
    );
  }
}