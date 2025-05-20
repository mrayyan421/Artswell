import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:artswellfyp/data/repositories/authenticationRepository/authenticationRepository.dart';
import '../../../features/personalization/models/addressModel.dart';

class AddressRepository {
  static final AddressRepository _instance = AddressRepository._internal();
  factory AddressRepository() => _instance;
  AddressRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthenticationRepository _authRepo = AuthenticationRepository();

  /// Get reference to user's address subcollection
  CollectionReference _userAddressCollection(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('addresses');
  }

  /// Initialize address subcollection with a default empty address
  Future<void> initializeUserAddresses(String userId, String name, String? phoneNumber) async {
    try {
      final addressRef = _userAddressCollection(userId).doc('default_$userId');
      final doc = await addressRef.get();

      if (!doc.exists) {
        await addressRef.set({
          'id': 'default_$userId',
          'userId': userId,
          'name': name.isNotEmpty ? name : 'User',
          'phoneNumber': phoneNumber ?? '',
          'address': '',
          'postalCode': '',
          'state': '',
          'city': '',
          'country': '',
          'isDefault': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw 'Failed to initialize addresses: ${e.toString()}';
    }
  }

  /// Add new address to user's subcollection
  Future<void> addAddress(AddressModel address) async {
    try {
      final userId = _authRepo.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      await _userAddressCollection(userId)
          .doc(address.id)
          .set(address.toJson());
    } catch (e) {
      throw 'Failed to add address: ${e.toString()}';
    }
  }

  /// Get all addresses for current user
  Future<List<AddressModel>> getUserAddresses() async {
    try {
      final userId = _authRepo.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      final snapshot = await _userAddressCollection(userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AddressModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get addresses: ${e.toString()}';
    }
  }

  /// Set default address
  Future<void> setDefaultAddress(String addressId) async {
    try {
      final userId = _authRepo.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      await _firestore.runTransaction((transaction) async {
        // Reset all addresses to non-default
        final snapshot = await _userAddressCollection(userId).get();
        for (var doc in snapshot.docs) {
          transaction.update(doc.reference, {'isDefault': false});
        }

        // Set the selected address as default
        transaction.update(
            _userAddressCollection(userId).doc(addressId),
            {'isDefault': true}
        );
      });
    } catch (e) {
      throw 'Failed to set default address: ${e.toString()}';
    }
  }

  /// Delete address with existence check
  Future<void> deleteAddress(String addressId) async {
    try {
      final userId = _authRepo.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      final docRef = _userAddressCollection(userId).doc(addressId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw 'Address does not exist';
      }

      // Prevent deleting default address
      final data = doc.data() as Map<String, dynamic>?;
      if (data?['isDefault'] == true) {
        throw 'Cannot delete default address';
      }

      await docRef.delete();
    } catch (e) {
      throw 'Failed to delete address: ${e.toString()}';
    }
  }
}