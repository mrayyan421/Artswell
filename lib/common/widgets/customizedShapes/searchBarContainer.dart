import 'dart:async';

import 'package:artswellfyp/features/shop/controllers/productController.dart';
import 'package:artswellfyp/features/shop/screens/productDetails/productDetailScreen/productDetailMain/productDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../utils/constants/colorConstants.dart';
import '../../../utils/theme/theme.dart';
import '../../../utils/constants/size.dart';

class SearchContainer extends StatefulWidget {
  const SearchContainer({
    super.key,
    required this.text,
    required this.iconImg,
    this.showBackground = true,
    this.showBorder = true,
    required this.width,
    this.isSearchable = true,
    this.onSortSelected,
    this.onSearchValue
  });

  final String text;
  final String iconImg;
  final bool showBackground, showBorder;
  final double width;
  final bool isSearchable;
  final Function(String)? onSortSelected;
  final Function(String)? onSearchValue;

  @override
  State<SearchContainer> createState() => _SearchContainerState();
}

class _SearchContainerState extends State<SearchContainer> {
  late TextEditingController _textEditingController;
  final productController = Get.put(ProductController());
  final FocusNode _searchFocusNode = FocusNode();
  bool _showResults = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_searchFocusNode.hasFocus && _textEditingController.text.isEmpty) {
      productController.clearSearch();
    }
  }
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      productController.searchQuery.value = value.trim();
    });
  }

  void _showSortMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy,
      ),
      items: [
        _buildMenuItem('Price: Low to High', 'priceLowToHigh'),
        _buildMenuItem('Price: High to Low', 'priceHighToLow'),
        _buildMenuItem('Latest', 'latest'),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String text, String value) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(text),
      onTap: () {
        widget.onSortSelected?.call(value);
      },
    );
  }



  Widget _buildSearchResultsBottomSheet() {
    return Container(
      height: Get.height * 0.7,
      padding: const EdgeInsets.all(kSizes.mediumPadding),
      decoration: BoxDecoration(
        color: kColorConstants.klAntiqueWhiteColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Obx(() {
        if (productController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productController.searchResults.isEmpty) {
          return Center(
            child: Text(
              'No results found for "${_textEditingController.text}"',
              style: kAppTheme.lightTheme.textTheme.bodyLarge,
            ),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: kSizes.gridViewSpace,
            crossAxisSpacing: kSizes.gridViewSpace,
            childAspectRatio: 0.65,
          ),
          itemCount: productController.searchResults.length,
          itemBuilder: (context, index) {
            final product = productController.searchResults[index];
            return GestureDetector(
              onTap: () {
                Get.back(); // Close search results
                // Navigate to product detail
                Get.to(ProductDetail(product: product));
              },
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Image.network(
                        product.productImages.isNotEmpty
                            ? product.productImages[0]
                            : 'assets/images/placeholder.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(kSizes.smallPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: kAppTheme.lightTheme.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'PKR ${product.productPrice.toStringAsFixed(2)}',
                            style: kAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isSearchable
          ? null
          : () => _showSortMenu(context),
      child: Container(
        width: widget.width,
        height: 45.0,
        padding: const EdgeInsets.fromLTRB(
          kSizes.mediumPadding,
          kSizes.smallPadding,
          kSizes.mediumPadding,
          kSizes.smallPadding,
        ),
        decoration: BoxDecoration(
          color: widget.showBackground
              ? kColorConstants.klSearchBarColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(kSizes.largeBorderRadius),
          border: widget.showBorder
              ? Border.all(
            color: kColorConstants.klShadowColor,
            width: 1.0,
          )
              : null,
        ),
        child: Row(
          children: <Widget>[
            Image.asset(widget.iconImg),
            const SizedBox(width: kSizes.smallPadding),
            widget.isSearchable
                ? Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: kSizes.smallestPadding),
                child: TextField(
                  controller: _textEditingController,
                  focusNode: _searchFocusNode,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: widget.text,
                    hintStyle: const TextStyle(
                        color: kColorConstants
                            .klDateTextBottomNavBarSelectedIconColor,
                        fontSize: 10),
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),
                  style: kAppTheme.lightTheme.textTheme.displayMedium,
                  onChanged: _onSearchChanged,
                  onSubmitted: (value) {
                    productController.searchQuery.value = value;
                    productController.loadProducts();
                  },
                  onTap: () {
                    if (_textEditingController.text.isNotEmpty) {
                      productController.searchQuery.value = _textEditingController.text;
                      productController.loadProducts();
                    }
                  },
                ),
              ),
            )
                : Text(
              widget.text,
              style: kAppTheme.lightTheme.textTheme.displaySmall,
            ),
          ],
        ),
      ),
    );
  }
}