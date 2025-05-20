import 'package:flutter/material.dart';

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
    this.onSortSelected, // Add this callback
  });

  final String text;
  final String iconImg;
  final bool showBackground, showBorder;
  final double width;
  final bool isSearchable;
  final Function(String)? onSortSelected; // Callback for sort selection

  @override
  State<SearchContainer> createState() => _SearchContainerState();
}

class _SearchContainerState extends State<SearchContainer> {
  late TextEditingController _textEditingController;
  late String _searchInput;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _searchInput = '';
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
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
                  decoration: InputDecoration(
                    hintText: widget.text,
                    hintStyle: const TextStyle(
                        color: kColorConstants
                            .klDateTextBottomNavBarSelectedIconColor,fontSize: 10),
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),
                  style: kAppTheme.lightTheme.textTheme.displayMedium,
                  onChanged: (value) {
                    _searchInput = value;
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
/*class SearchContainer extends StatefulWidget {
  const SearchContainer({
    super.key,
    required this.text,
    required this.iconImg,
    this.showBackground = true,
    this.showBorder = true,
    required this.width,
    this.isSearchable = true,
    this.onSortSelected
  });
  final String text;
  final String iconImg;
  final bool showBackground, showBorder;
  final double width;
  final bool isSearchable;
  final Function(String)? onSortSelected;

  @override
  State<SearchContainer> createState() => _SearchContainerState();
}

class _SearchContainerState extends State<SearchContainer> {
  late TextEditingController _textEditingController;
  late String _searchInput;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _searchInput = '';
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isSearchable
          ? null
          : () {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(100, 100, 100, 100),
          items: [
            PopupMenuItem(child: Text('Price: Low to High')),
            PopupMenuItem(child: Text('Price: High to Low')),
            PopupMenuItem(child: Text('Latest')),
          ],
        );
      },
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
                padding: const EdgeInsets.only(top:kSizes.smallestPadding),
                child: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: widget.text,
                    hintStyle: TextStyle(color: kColorConstants.klDateTextBottomNavBarSelectedIconColor),
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),style: kAppTheme.lightTheme.textTheme.displayMedium,
                  onChanged: (value) {
                    _searchInput = value;
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
      )
    );
  }
}*/