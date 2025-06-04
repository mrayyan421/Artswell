//TODO: Resusable class
import 'package:artswellfyp/common/widgets/commonWidgets/titleText.dart';
import 'package:artswellfyp/features/personalization/controllers/addressController.dart';
import 'package:flutter/material.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:get/get.dart';

import '../../../personalization/models/addressModel.dart';

class kBillingAddressSection extends StatelessWidget {
  kBillingAddressSection({super.key});
  final addressCtrl = Get.put(AddressController());

  // to store the selected address locally in this widget
  final Rx<AddressModel?> selectedBillingAddress = Rx<AddressModel?>(null);

  void _showAddressSelectionDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(kSizes.mediumPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(kSizes.mediumPadding),
            topRight: Radius.circular(kSizes.mediumBorderRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Shipping Address',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: kSizes.mediumPadding),
            Obx(() {
              if (addressCtrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: addressCtrl.addresses.length,
                  itemBuilder: (context, index) {
                    final address = addressCtrl.addresses[index];
                    return ListTile(
                      leading: Icon(Icons.location_on,
                          color: address.isDefault
                              ? Colors.green
                              : Colors.grey),
                      title: Text(address.name),
                      subtitle: Text(
                        '${address.address}, ${address.city}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: selectedBillingAddress.value?.id == address.id ||
                          address.isDefault
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        // Update the selected billing address locally
                        selectedBillingAddress.value = address;
                        Get.back();
                      },
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: kSizes.mediumPadding),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          title: 'Shipping Address',
          showAction: true,
          btnTitle: 'Change',
          onPressed: () => _showAddressSelectionDialog(context),
        ),
        Obx(() {
          // Use the selected billing address if available, otherwise use the default address
          final displayAddress = selectedBillingAddress.value ??
              addressCtrl.selectedAddress.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayAddress?.name ?? 'No name',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: kSizes.mediumPadding / 2),
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.grey, size: 16),
                  const SizedBox(width: kSizes.mediumPadding),
                  Text(
                    displayAddress?.phoneNumber ?? '+92-31*-*******',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: kSizes.mediumPadding / 2),
              Row(
                children: [
                  const Icon(Icons.location_history, color: Colors.grey, size: 16),
                  const SizedBox(width: kSizes.mediumPadding),
                  Expanded(
                    child: Text(
                      displayAddress != null
                          ? '${displayAddress.address}, ${displayAddress.city}, ${displayAddress.country}'
                          : 'No address selected',
                      style: Theme.of(context).textTheme.bodyMedium,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }
}