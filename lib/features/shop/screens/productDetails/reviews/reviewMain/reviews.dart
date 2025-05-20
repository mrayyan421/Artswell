import 'package:artswellfyp/utils/device/deviceComponents.dart';
import 'package:flutter/material.dart';
import '../../../../../../utils/constants/size.dart';
import '../reviewProgressIndicator.dart';

class kReviewSection extends StatelessWidget {
  const kReviewSection({
    super.key,
    required this.ratingText, //both these variables to be fetched from analytics api
    required this.indicatorValue,
    required this.overallRatingText
  });
  final String ratingText;
  final String overallRatingText;
  final double indicatorValue;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment:CrossAxisAlignment.start,children: [Text('Ratings & Reviews are verified before publication',style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: kSizes.mediumPadding),
        Row(
          children: [
            Expanded(flex:0,child: Text(overallRatingText,style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 70),)),
            const SizedBox(width: kSizes.mediumPadding,),
            Expanded(flex: 7,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(flex: 1, child: Text('', style: Theme.of(context).textTheme.bodySmall)),
                      Expanded(
                        flex: 7,
                        child: SizedBox(
                          width: kDeviceComponents.screenWidth(context)* 0.8,
                          child: const Column(
                            children: [
                              reviewProgressIndicator(text: '5', value: 0.7,),
                              // const SizedBox(height: kSizes.smallestPadding,),
                              reviewProgressIndicator(text: '4', value: 0.5,),
                              // const SizedBox(height: kSizes.smallestPadding,),
                              reviewProgressIndicator(value: 0.3, text: '3',),
                              // const SizedBox(height: kSizes.smallestPadding,),
                              reviewProgressIndicator(value: 0.1, text: '2',),
                              // const SizedBox(height: kSizes.smallestPadding,),
                              reviewProgressIndicator(value: 0.05, text: '1',),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )
        ,],),);
  }
}


