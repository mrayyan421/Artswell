import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SellerStory extends StatefulWidget {
  final String sellerId;
  final String shopName;

  const SellerStory({
    Key? key,
    required this.sellerId,
    required this.shopName,
  }) : super(key: key);

  @override
  _SellerStoryState createState() => _SellerStoryState();
}

class _SellerStoryState extends State<SellerStory> {
  late Future<Map<String, dynamic>> _sellerStoryFuture;

  @override
  void initState() {
    super.initState();
    _sellerStoryFuture = _fetchSellerStory();
  }

  Future<Map<String, dynamic>> _fetchSellerStory() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.sellerId)
          .collection('seller_stories')
          .doc(widget.sellerId)
          .get();

      if (doc.exists) {
        return doc.data()!;
      }
      return {
        'shopName': widget.shopName,
        'successStory': 'No story available yet',
        'profileImageUrl': '',
        'shopDetails': '',
      };
    } catch (e) {
      print('Error fetching seller story: $e');
      return {
        'shopName': widget.shopName,
        'successStory': 'Failed to load story',
        'profileImageUrl': '',
        'shopDetails': '',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.shopName}\'s Story'),
        centerTitle: true,
        elevation: 0,
        leading: GestureDetector(onTap: ()=>Get.back(), child: const ImageIcon(AssetImage('assets/icons/leftArrow.png'))),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _sellerStoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final storyData = snapshot.data!;
          final profileImage = storyData['profileImageUrl'] as String;
          final successStory = storyData['successStory'] as String;
          final shopDetails = storyData['shopDetails'] as String;
          final shopName = storyData['shopName'] as String;
          final remarks=storyData['remarks'] as String;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Profile Section
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      if (profileImage.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: profileImage,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const ImageIcon(AssetImage('assets/icons/acct.png'), size: 60),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shopName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (shopDetails.isNotEmpty)
                              Text(
                                shopDetails,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Story Content Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Our Story',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        successStory,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 30),
                      // Shop Details Section
                      if (shopDetails.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 15),
                        const Text(
                          'About Our Shop',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          shopDetails,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const Divider(),
                        const SizedBox(height: 15),

                        const Text(
                          'Remarks/Experience',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),

                        Text(
                          remarks,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}