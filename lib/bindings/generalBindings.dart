import 'package:artswellfyp/utils/http/networkManager.dart';
import 'package:get/get.dart';

class GeneralBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(NetworkManager());
  }
}