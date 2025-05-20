import 'package:flutter/material.dart';

import '../../../../../utils/constants/colorConstants.dart';
import '../../../../../utils/theme/theme.dart';
import '../../../models/productModel.dart';

class kStockText extends StatelessWidget {
  final ProductModel product;
  const kStockText({
    super.key,
    required this.product
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Text.rich(TextSpan(children:[
            TextSpan(text: 'In-Stock:',style: kAppTheme.lightTheme.textTheme.titleMedium),
          ] ))
        ],),
        Row(children: [
          Text.rich(TextSpan(children: [
            TextSpan(text: product.inStock.toString(),style: kAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: kColorConstants.klSearchBarColor,fontStyle: FontStyle.italic),)//create a List of stock ['In stock,Out of stock,']
          ]))
        ],)],
    );
  }
}