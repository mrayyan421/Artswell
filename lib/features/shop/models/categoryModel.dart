import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String id;
  String name;
  String image;
  String parentId;
  bool isFeatured;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.parentId = '',
    required this.isFeatured,
  });

  //empty helper func to be used if no category exists
  static CategoryModel empty() =>
      CategoryModel(id: '', name: '', image: '', isFeatured: false);

  //CategoryModel to json
  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Image': image,
      'ParentId': parentId,
      'isFeatured': isFeatured
    };
  }

  //Map json document from fb to UserModel
  factory CategoryModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? {};

    return CategoryModel(
      id: document.id,
      name: data['Name'] as String? ?? "",
      image: data['Image'] as String? ?? "",
      parentId: data['ParentId'] as String? ?? "",
      isFeatured: data['isFeatured'] as bool? ?? false,
    );
  }
}
