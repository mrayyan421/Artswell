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

/*class OrderslistItems extends StatelessWidget {
  const OrderslistItems({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // scrollDirection: Axis.vertical,
      itemCount: 2,
      shrinkWrap: true,
      separatorBuilder: (_,__)=>const SizedBox(height:kSizes.mediumPadding,),
      itemBuilder:(_,index)=> kCircularContainer(
        showBorder: true,
        padding: const EdgeInsets.all(kSizes.mediumPadding),
        backgroundColor: kColorConstants.klAntiqueWhiteColor,
        width: null,
        height: null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ImageIcon(AssetImage('assets/icons/ship.png')),
                SizedBox(width: kSizes.mediumPadding / 2),
                Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Processing', //to be fetched from api and make list of [Pending,Processing,Shipped,Out for Delivery,cancelled]
                        style: Theme.of(context).textTheme.bodyLarge!.apply(color: kColorConstants.klPrimaryColor, fontWeightDelta: 1),),
                      Text(
                        '01 March 2025', //to be fetched from API
                        style: Theme.of(context).textTheme.headlineSmall!,
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderDetailCard())); //use getx instead
                },
                    icon: const ImageIcon(
                        AssetImage('assets/icons/rightArrow.png'),
                        size: kSizes.largeIcon)),
              ],
            ),
            SizedBox(height: kSizes.mediumPadding,),
            Row(children: [
                Expanded(child: Row(children: [
                      ImageIcon(AssetImage('assets/icons/cart.png')),
                      SizedBox(width: kSizes.mediumPadding / 2),
                      Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order',style: Theme.of(context).textTheme.bodyMedium!.apply(fontWeightDelta: 1,fontStyle: FontStyle.italic),),
                            Text(
                              'AW-007', //to be fetched from API
                              style: Theme.of(context).textTheme.headlineSmall!,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      ImageIcon(AssetImage('assets/icons/calendar.png')),
                      SizedBox(width: kSizes.mediumPadding / 2),
                      Expanded(
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              'Estimated delivery', //to be fetched from api and make list of [Pending,Processing,Shipped,Out for Delivery,cancelled]
                              style: Theme.of(context).textTheme.bodyMedium!.apply(fontStyle: FontStyle.italic, fontWeightDelta: 1),),
                            Text(
                              '05 March 2025', //to be fetched from API
                              style: Theme.of(context).textTheme.headlineSmall!,),
                          ],),),
                    ],),),
              ],),
          ],),
      ),
    );
  }
}*/
