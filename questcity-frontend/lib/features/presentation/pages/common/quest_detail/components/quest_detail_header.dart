import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_list_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/cubit/quest_detail_screen_cubit.dart';

class QuestDetailHeader extends StatelessWidget {
  final QuestItem questItem;
  final QuestDetails? questDetails;

  const QuestDetailHeader({
    super.key,
    required this.questItem,
    this.questDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Quest Image
            Positioned.fill(
              child: Image.network(
                questItem.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: UiConstants.grayColor,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64.w,
                      color: UiConstants.whiteColor,
                    ),
                  );
                },
              ),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Quest Name and Rating
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questItem.name,
                    style: UiConstants.textStyle1.copyWith(
                      color: UiConstants.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),

                  // Rating Row
                  Row(
                    children: [
                      Icon(
                        Icons.star_rate_rounded,
                        color: UiConstants.yellowColor,
                        size: 20.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        questItem.rating?.toStringAsFixed(1) ?? "0.0",
                        style: UiConstants.textStyle4.copyWith(
                          color: UiConstants.whiteColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "(${questDetails?.reviews.length ?? 0} reviews)",
                        style: UiConstants.textStyle5.copyWith(
                          color: UiConstants.whiteColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price Badge (if not free)
            if (questItem.mainPreferences.price.amount != null &&
                questItem.mainPreferences.price.amount! > 0)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: Container(
                  padding: getMarginOrPadding(
                    left: 12,
                    right: 12,
                    top: 6,
                    bottom: 6,
                  ),
                  decoration: BoxDecoration(
                    color: UiConstants.greenColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    questItem.mainPreferences.price.isSubscription == true
                        ? "Subscription"
                        : "\$${questItem.mainPreferences.price.amount}",
                    style: UiConstants.textStyle5.copyWith(
                      color: UiConstants.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
