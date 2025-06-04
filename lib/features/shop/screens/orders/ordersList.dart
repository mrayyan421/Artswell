import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../controllers/orderController.dart';
import '../../models/orderModel.dart';

class OrderslistItems extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  OrderslistItems({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: OrderController().getCartItemsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final order = snapshot.data![index];
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('products').doc(order.items.first.productId).get(),
              builder: (context, productSnapshot) {
                if (!productSnapshot.hasData) return const ListTile(title: Text('Loading...'));

                final product = productSnapshot.data!.data() as Map<String, dynamic>;

                return ListTile(
                  leading: Image.network(product['thumbnail'],cacheHeight: 80,cacheWidth: 80,headers: const {"Cache-Control": "no-cache"},),
                  title: Text(product['name']),
                  subtitle: Text('Qty: ${order.items.first.quantity}'),
                  trailing: Text('\$${product['price'] * order.items.first.quantity}'),
                );
              },
            );
          },
        );
      },
    );
  }
}

