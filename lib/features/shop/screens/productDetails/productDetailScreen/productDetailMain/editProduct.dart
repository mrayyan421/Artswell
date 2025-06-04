import 'dart:io';

import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';
import 'package:artswellfyp/data/repositories/productRepository/productRepository.dart';
import 'package:artswellfyp/features/shop/controllers/homeController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/productController.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  const EditProductScreen({super.key, required this.productId});
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final RxList<File> _images = <File>[].obs;
  final _repo = Get.put(ProductRepository());
  final product = ProductController.instance.selectedProduct.value;
  final controller=Get.put(ProductController());
  // final transactionCtrl=Get.put(TransactionController());
  final RxBool _isBiddable = false.obs;
  final RxBool _inStock = true.obs;
  final RxString _selectedCategory = 'calligraphy'.obs;
  final List<String> _categories = [
    'calligraphy',
    'clothes',
    'stone art',
    'truck art',
    'wood art'
  ];

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    try {
      final product = await _repo.getProductById(widget.productId);
      _nameCtrl.text = product.productName;
      _descCtrl.text = product.productDescription;
      _priceCtrl.text = product.productPrice.toString();
      _isBiddable.value = product.isBiddable;
      _inStock.value = product.inStock;
      if (_categories.contains(product.category)) {
        _selectedCategory.value = product.category;
      } else {
        _selectedCategory.value = _categories.first;
      }
        } catch (e) {
      kLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load product data: ${e.toString()}',
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: HomeController.instance.returnPage,
            child: const ImageIcon(
              AssetImage('assets/icons/leftArrow.png'),
            )),
        title: const Text("Edit Product"),
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
            Obx(() => CheckboxListTile(
              title: const Text('In Stock'),
              value: _inStock.value,
              onChanged: (bool? value) {
                if (value != null) {
                  _inStock.value = value;
                }
              },
            )),
            const SizedBox(height: 20.0),
            // Dropdown for category selection
            Obx(() => DropdownButtonFormField<String>(
              value: _categories.contains(_selectedCategory.value)
                  ? _selectedCategory.value
                  : _categories.first,
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
            const SizedBox(height: 20.0),
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
              onPressed: () {
                if (product == null) {
                  kLoaders.errorSnackBar(
                    title: 'Incomplete details Error…',
                    message: 'Enter Product details & save them first to upload',
                  );
                  return;
                }
                ProductController.instance.setSecondaryImages(product!.id);
              },
              child: const Text("Select Other Images"),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _repo.updateProduct(
                    id: widget.productId,
                    name: _nameCtrl.text.trim(),
                    description: _descCtrl.text.trim(),
                    price: int.tryParse(_priceCtrl.text.trim()) ?? 0,
                    inStock: _inStock.value,
                    isBiddable: _isBiddable.value,
                    category: _selectedCategory.value,
                  );

                  kLoaders.successSnackBar(
                    title: 'Success',
                    message: 'Product updated successfully',
                  );

                  Get.back();
                } catch (e) {
                  kLoaders.errorSnackBar(
                    title: 'Error',
                    message: 'Failed to update product: ${e.toString()}',
                  );
                }
              },
              child: const Text("Update Product"),
            ),
          ],
        ),
      ),
    );
  }
}