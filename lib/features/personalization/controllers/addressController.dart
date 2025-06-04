import 'package:get/get.dart';
import '../../../common/widgets/loaders/basicLoaders.dart';
import '../../../data/repositories/authenticationRepository/authenticationRepository.dart';
import '../../../data/repositories/userRepository/addressRepository.dart';
import '../models/addressModel.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  final AddressRepository _addressRepository = AddressRepository();
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    fetchAddresses();
    super.onInit();
  }

  /// Fetch all addresses for current user
  Future<void> fetchAddresses() async {
    try {
      isLoading(true);
      final userAddresses = await _addressRepository.getUserAddresses();
      addresses.assignAll(userAddresses);

      // Set default address if none is selected
      if (selectedAddress.value == null) {
        selectedAddress.value = userAddresses.firstWhereOrNull(
                (addr) => addr.isDefault
        ) ?? (userAddresses.isNotEmpty ? userAddresses.first : null);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load addresses: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  /// Add new address
  Future<void> addNewAddress(AddressModel newAddress) async {
    try {
      isLoading(true); // Show loading state
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      // Add the address
      await _addressRepository.addAddress(newAddress);

      // Refresh the addresses list
      await fetchAddresses();

      // Show success message
      Get.closeCurrentSnackbar(); // Close any existing snackbars
      kLoaders.successSnackBar(
        title: 'Success',
        message: 'Address added successfully',
      );
      Get.back();
    } catch (e) {
      Get.closeCurrentSnackbar(); // Close any existing snackbars
      kLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to add address: ${e.toString()}',
      );
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  /// Set default address
  Future<void> setDefaultAddress(String addressId) async {
    try {
      // Update local state first
      for (var address in addresses) {
        address.isDefault = address.id == addressId;
      }
      selectedAddress.value = addresses.firstWhere((addr) => addr.id == addressId);

      // Update in repository
      await _addressRepository.setDefaultAddress(addressId);

      // Show success message
      kLoaders.successSnackBar(
        title: 'Success',
        message: 'Default address updated successfully',
      );
    } catch (e) {
      // Revert changes if error occurs
      fetchAddresses();
      kLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to set default address: ${e.toString()}',
      );
    }
  }

  /// Delete address - Fixed version
  Future<void> deleteAddress(String addressId) async {
    try {
      await _addressRepository.deleteAddress(addressId);
      await fetchAddresses(); // Refresh the list
      kLoaders.successSnackBar(
          title: 'Success',
          message: 'Address deleted successfully'
      );
    } catch (e) {
      kLoaders.errorSnackBar(title: 'Error', message: e.toString());
      rethrow;
    }
  }
}