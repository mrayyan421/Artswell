import 'package:get_storage/get_storage.dart';

//Singleton class for handling local storage
//Design pattern used==Factory method
class kLocalStorage{
  kLocalStorage._internal();
  final _getXStorage=GetStorage();
  static final kLocalStorage _localStorageInstance=kLocalStorage._internal();
  factory kLocalStorage(){//factory method for dealing with localStorage
    return _localStorageInstance;
  }
  Future<void> saveData<K>(String key, K value)async{//Asynchronous function to SAVE Data with write functionality
    await _getXStorage.write(key, value);
  }
  Future<void> readData<K>(String key)async{//Asynchronous function to READ Data with read functionality
    await _getXStorage.read(key);
  }
  Future<void> removeData<K>(String key)async{//Asynchronous function to REMOVE Data with remove functionality
    await _getXStorage.remove(key);
  }
  Future<void> eraseData<K>()async{//Asynchronous function to ERASE all Data with erase functionality
    await _getXStorage.erase();
  }
}