import 'package:artswellfyp/common/widgets/circularContainer.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/device/deviceComponents.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants/size.dart';
import '../../models/addressModel.dart';

class kAddressContainer extends StatelessWidget {
  const kAddressContainer({
    super.key,
    required this.address,
    required this.selectedAddress,
    required this.onTap,
  });

  final AddressModel address;
  final bool selectedAddress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: kSizes.mediumPadding),
        child: kCircularContainer(
          padding: const EdgeInsets.all(kSizes.largeBorderRadius),
          height: kDeviceComponents.screenHeight(context) / 6.5,
          width: double.infinity,
          showBorder: true,
          backgroundColor: selectedAddress
              ? Color.fromRGBO(
            kColorConstants.klVisitStoreElevationBtnClr.r.toInt(),
            kColorConstants.klVisitStoreElevationBtnClr.g.toInt(),
            kColorConstants.klVisitStoreElevationBtnClr.b.toInt(),
            0.2, // This replaces withOpacity(0.2)
          )
              : Colors.transparent,
          margin: const EdgeInsets.only(bottom: kSizes.mediumPadding),
          child: Stack(
            children: [
              if (selectedAddress)
                Positioned(
                  right: 5,
                  top: 0,
                  child: Image.asset(
                    'assets/icons/check.png',
                    width: 24,
                    height: 24,
                    color: kColorConstants.klVisitStoreElevationBtnClr,
                  ),
                ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.name,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: selectedAddress ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      '${address.address}, ${address.city}, ${address.country}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selectedAddress ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: kSizes.mediumPadding / 2),
                    Text(
                      address.phoneNumber,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: selectedAddress ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}