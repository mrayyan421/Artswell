import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:artswellfyp/utils/device/deviceComponents.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artswellfyp/utils/theme/theme.dart';

import '../../../../../common/widgets/loaders/basicLoaders.dart';
import '../../../../../data/repositories/authenticationRepository/authenticationRepository.dart';
import '../../../controllers/addressController.dart';
import '../../../models/addressModel.dart';

class AddNewAddress extends StatefulWidget {
  const AddNewAddress({super.key});

  @override
  _AddNewAddressState createState() => _AddNewAddressState();
}

class _AddNewAddressState extends State<AddNewAddress> {
  final _formKey = GlobalKey<FormState>();
  final AddressController _addressCtrl = Get.put(AddressController()); // Renamed

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressFieldController = TextEditingController(); // Renamed
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressFieldController.dispose(); // Updated
    _postalCodeController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorConstants.klPrimaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const ImageIcon(AssetImage('assets/icons/leftArrow.png')),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Add Address',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(kSizes.mediumPadding),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: const ImageIcon(
                        AssetImage('assets/icons/acct.png'),
                        color: Colors.black
                    ),
                    labelText: 'Name',
                    labelStyle: kAppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
                ),
                const SizedBox(height: kSizes.mediumPadding),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    prefixIcon: const ImageIcon(
                        AssetImage('assets/icons/phoneNo.png'),
                        color: Colors.black
                    ),
                    labelText: 'Phone Number',
                    labelStyle: kAppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter phone number' : null,
                ),
                const SizedBox(height: kSizes.mediumPadding),
                TextFormField(
                  controller: _addressFieldController, // Updated
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    prefixIcon: const ImageIcon(
                        AssetImage('assets/icons/home.png'),
                        color: Colors.black
                    ),
                    labelText: 'Address',
                    labelStyle: kAppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter address' : null,
                ),
                const SizedBox(height: kSizes.mediumPadding),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stateController,
                        decoration: InputDecoration(
                          prefixIcon: const ImageIcon(
                              AssetImage('assets/icons/state.png'),
                              color: Colors.black
                          ),
                          labelText: 'State',
                          labelStyle: kAppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter state' : null,
                      ),
                    ),
                    const SizedBox(width: kSizes.mediumPadding),
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          prefixIcon: const ImageIcon(
                              AssetImage('assets/icons/city.png'),
                              color: Colors.black
                          ),
                          labelText: 'City',
                          labelStyle: kAppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter city' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kSizes.mediumPadding),
                TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    prefixIcon: const ImageIcon(
                        AssetImage('assets/icons/country.png'),
                        color: Colors.black,
                      size: 40,
                    ),
                    labelText: 'Country',
                    labelStyle: kAppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter country' : null,
                ),
                const SizedBox(height: kSizes.mediumPadding),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: kDeviceComponents.screenWidth(context) * 0.48,
                    child: TextFormField(
                      controller: _postalCodeController,
                      decoration: InputDecoration(
                        prefixIcon: const ImageIcon(
                            AssetImage('assets/icons/phoneNo.png'),
                            color: Colors.black
                        ),
                        labelText: 'Postal Code',
                        labelStyle: kAppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter postal code' : null,
                    ),
                  ),
                ),
                const SizedBox(height: kSizes.mediumPadding),
                Row(
                  children: [
                    Checkbox(
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'Set as default address',
                      style: kAppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: kSizes.mediumPadding),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kColorConstants.klSecondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                      'Save Address',
                      style: kAppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newAddress = AddressModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: AuthenticationRepository.instance.authUser?.uid ?? '',
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressFieldController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        state: _stateController.text.trim(),
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        isDefault: _isDefault,
        createdAt: Timestamp.now(), // datetime is not recofnzed by firestore
      );

      await _addressCtrl.addNewAddress(newAddress);

      if (_isDefault) {
        await _addressCtrl.setDefaultAddress(newAddress.id);
      }

      Get.back();
    } catch (e) {
      kLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }}}