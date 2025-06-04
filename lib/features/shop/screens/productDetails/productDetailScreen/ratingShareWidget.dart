import 'dart:io';

import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';
import 'package:artswellfyp/features/shop/models/productModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../utils/constants/colorConstants.dart';
import '../../../../../utils/constants/size.dart';
import '../../../controllers/productController.dart';

class kRatingAndShare extends StatelessWidget {
  final ProductModel product;
  final double rating;
  const kRatingAndShare({
    super.key,
    required this.product,
    required this.rating
  });

  @override
  Widget build(BuildContext context) {
    Future<File> downloadImage(String url) async {
      final response = await http.get(Uri.parse(url));
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/product_thumbnail.png');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    }
    final productCtrl = Get.put(ProductController());
    final commentCount = product.comments.length;
    final rating = product.reviewCount;
    final displayRating = rating.toStringAsFixed(1);


    Future<void> shareProduct(BuildContext context) async {
      try {
        // final product = productCtrl.selectedProduct.value;
        if (product.productImages.isEmpty) return;
        final imageUrl = (product.primaryImageIndex != null && product.primaryImageIndex! < product.productImages.length) ? product.productImages[product.primaryImageIndex!] : product.productImages.first;

        final imageFile = await downloadImage(imageUrl);
        final shareText = '''
        🌟 ${product.productName} 🌟

        💰 Price: PKR ${product.productPrice}

        📝 ${product.productDescription}

        Discover more on ArtsWell!
        ''';//link to app here
        final box = context.findRenderObject() as RenderBox?;

        await SharePlus.instance.share(
          ShareParams(
            text: shareText,
            subject: 'Check out this product!',
            files: [XFile(imageFile.path)],
            sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          ),
        );
      } catch (e) {
        kLoaders.errorSnackBar(
          title: 'Failed to share...',
          message: 'Could not share the product: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Rating and Comment Count
        const Row(
          children: [
            ImageIcon(
              AssetImage('assets/icons/ratingIconColored.png'),
              color: kColorConstants.klOrangeColor,
              size: 32,
            ),
            SizedBox(width: kSizes.gridViewSpace / 2),
          ],
        ),
        // Share Button
        IconButton(
          onPressed: () =>shareProduct(context),
          icon: const ImageIcon(
            AssetImage('assets/icons/share.png'),
            size: kSizes.mediumIcon,
          ),
        ),
      ],
    );
  }
}