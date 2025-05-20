import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(onTap: ()=>Get.back(),child: const ImageIcon(AssetImage('assets/icons/leftArrow.png')),),
        title: const Text('About Us'),
        backgroundColor: kColorConstants.klPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 20,
                vertical: 30,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Who We Are',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                        'We are a dedicated team committed to empowering artisans through accessible digital solutions. '
                            'With specialized experience in bridging traditional craftsmanship with modern technology, '
                            'we create platforms that enhance digital literacy and expand market opportunities. '
                            'Our mission is to equip artisans with user-friendly tools that preserve cultural heritage '
                            'while enabling growth in the digital economy. By combining practical training with '
                            'innovative platforms, we help transform traditional skills into sustainable digital ventures.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.blueGrey[50],
              child: Column(
                children: [
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ImageIcon(const AssetImage('assets/icons/mail.png'), color: Colors.blueGrey[600], size: 20),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _launchEmail(),
                        child: Text(
                          'fproject219@gmail.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[600],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We typically respond within 24 hours',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'fproject219@gmail.com',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch email';
    }
  }
}