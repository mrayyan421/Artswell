import 'dart:io';

import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/productController.dart';

class AddProductScreen extends StatelessWidget {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final RxList<File> _images = <File>[].obs;
  final controller = Get.put(ProductController());
  final product = ProductController.instance.selectedProduct.value;
  final RxBool _isBiddable = false.obs;
  final RxString _selectedCategory = 'calligraphy'.obs;
  final List<String> _categories = [
    'calligraphy',
    'clothes',
    'stone Art',
    'truck Art',
    'wood'
  ];

  AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap:()=> Get.back(),
            child: const ImageIcon(
              AssetImage('assets/icons/leftArrow.png'),
            )),
        title: const Text("New Product"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(height: 20.0),
            TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: "Description")),
            const SizedBox(height: 20.0),
            TextField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number),
            const SizedBox(height: 20.0),
            Obx(() => CheckboxListTile(
              title: const Text('Make Biddable'),
              value: _isBiddable.value,
              onChanged: (bool? value) {
                if (value != null) {
                  _isBiddable.value = value;
                }
              },
            )),
            const SizedBox(height: 20.0),
            // Dropdown for category selection
            Obx(() => DropdownButtonFormField<String>(
              value: _selectedCategory.value,
              icon: const ImageIcon(AssetImage('assets/icons/dropDownBtn.png')),
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _selectedCategory.value = value;
                }
              },
            )),
            Obx(() => Wrap(
              children: _images
                  .map((f) => Image.file(f, width: 80, height: 80))
                  .toList(),
            )),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                final prod = controller.selectedProduct.value;
                if (prod == null) {
                  kLoaders.errorSnackBar(
                      title: 'Incomplete details Error...',
                      message:
                      'Enter Product details & save them first to upload');
                  return;
                }
                if (controller.selectedProduct.value?.id != null) {
                  controller
                      .pickAndUploadImage(controller.selectedProduct.value!.id);
                  kLoaders.successSnackBar(
                      title: 'Upload Successful',
                      message:
                      'Image uploaded and set as Product Thumbnail ;-)');
                }
              },
              child: const Text("Pick Thumbnail Image"),
            ),
            const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () async {
              if (controller.selectedProduct.value?.id == null) {
                kLoaders.errorSnackBar(
                    title: 'Error',
                    message: 'Please save product first'
                );
                return;
              }

              try {
                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );

                await controller.setSecondaryImages(controller.selectedProduct.value!.id);

                Get.back();
              } catch (e) {
                Get.back();
                kLoaders.errorSnackBar(
                    title: 'Error',
                    message: 'Failed to add images: ${e.toString()}'
                );
              }
            },
            child: const Text("Select Other Images"),
          ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async{
                try {
                  final id = await controller.add(
                      name: _nameCtrl.text,
                      description: _descCtrl.text,
                      images: _images.toList(),
                      price: int.parse(_priceCtrl.text),
                      feedback: [],
                      reviewCount: 0,
                      isBiddable: _isBiddable.value,
                      category: _selectedCategory.value,
                      createdAt: Timestamp.now(),
                      averageRating: 0.0
                  );

                  // After adding, don't immediately overwrite selectedProduct to empty
                  // Instead, reload products and assign the newly created product properly
                  await controller.loadProducts();
                  controller.selectedProduct.value =
                      controller.products.firstWhere((p) => p.id == id);

                  await controller.pickAndUploadImage(id);
                  Get.back();
                } catch (e) {
                  print(e);
                  kLoaders.errorSnackBar(
                      title: 'Upload Failed',
                      message: 'Failed to upload image, Try again... ${e.toString()}');
                }
              },
              child: const Text("Save"),
            ),
            /*ElevatedButton(
              onPressed: ()async {
                try {
                  final id = await controller.add(
                    name: _nameCtrl.text,
                    description: _descCtrl.text,
                    images: _images.toList(),
                    price: int.parse(_priceCtrl.text),
                    feedback: [],
                    reviewCount: 0,
                    isBiddable: _isBiddable.value,
                    category: _selectedCategory.value,
                    createdAt: Timestamp.now(),
                    averageRating: 0.0
                  );

                  // After adding, don't immediately overwrite selectedProduct to empty
                  // Instead, reload products and assign the newly created product properly
                  await controller.loadProducts();
                  controller.selectedProduct.value =
                      controller.products.firstWhere((p) => p.id == id);

                  await controller.pickAndUploadImage(id);
                  Get.back();
                } catch (e) {
                  print(e);
                  kLoaders.errorSnackBar(
                      title: 'Upload Failed',
                      message: 'Failed to upload image, Try again... ${e.toString()}');
                }
              },
                /*async {
                try {
                  final id = await controller.add(
                      name: _nameCtrl.text,
                      description: _descCtrl.text,
                      images: _images.toList(),
                      price: int.parse(_priceCtrl.text),
                      feedback: [],
                      reviewCount: 0,
                  );
                  controller.selectedProduct.value = ProductModel(
                      id: id,
                      productName: _nameCtrl.text,
                      productImages: [],
                      primaryImageIndex: 0,
                      inStock: true,
                      isBiddable: _isBiddable.value,
                      isFavorite: false,
                      productDescription: _descCtrl.text,
                      productPrice: int.parse(_priceCtrl.text),
                      sellerId: UserController.instance.user.value.uid,
                      comment: '',
                      category: _selectedCategory.value,
                      feedback:
                      controller.selectedProduct.value?.feedback ?? <String>[],
                      reviewCount:
                      controller.selectedProduct.value?.reviewCount ?? 0);
                  await controller.pickAndUploadImage(id);
                  Get.back();
                } catch (e) {
                  print(e);
                  kLoaders.errorSnackBar(
                      title: 'Upload Failed',
                      message:
                      'Failed to upload image, Try again... ${e.toString()}');
                }
              },*/
              child: Text("Save"),
            ),*/
          ],
        ),
      ),
    );
  }
}
