import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/reviews_screen/reviews_screen.dart';

import '../../../../../data/models/quests/quest_model.dart';

class QuestRatingView extends StatelessWidget {
  final List<Review> reviews;
  final String questName;
  const QuestRatingView({super.key, required this.reviews, required this.questName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        FadeInRoute(
            ReviewsScreen(
              reviews: reviews,
              questName: questName,
            ),
            Routes.reviewsScreen),
      ),
      child: Container(
        padding: getMarginOrPadding(top: 7, bottom: 7, left: 20, right: 10),
        decoration: BoxDecoration(
          color: UiConstants.purpleColor,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          children: [
            Icon(Icons.star_rounded, color: UiConstants.yellowColor, size: 21.w),
            SizedBox(width: 2.w),
            Text(
              '5',
              style: UiConstants.textStyle4.copyWith(color: UiConstants.whiteColor),
            ),
            SizedBox(width: 5.w),
            Icon(Icons.keyboard_arrow_right_rounded, color: UiConstants.whiteColor, size: 25.w),
          ],
        ),
      ),
    );
  }
}
