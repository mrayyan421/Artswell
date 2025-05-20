import 'package:artswellfyp/common/widgets/customizedShapes/appBar.dart';
import 'package:artswellfyp/features/shop/screens/orders/ordersList.dart';
import 'package:flutter/material.dart';
import 'package:artswellfyp/utils/constants/size.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(kSizes.mediumPadding),
        // -- Orders
        child: SingleChildScrollView(child: Column(
          children: [
            Text('Order History',style: Theme.of(context).textTheme.headlineLarge),
            OrderslistItems(),
          ],
        )),
      ), // Padding
    ); // Scaffold
  }
}
