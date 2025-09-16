import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/cubit/quest_detail_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class QuestDetailReviewsSection extends StatelessWidget {
  final List<QuestReview> reviews;

  const QuestDetailReviewsSection({
    super.key,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: getMarginOrPadding(all: 16),
      decoration: BoxDecoration(
        color: UiConstants.whiteColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: UiConstants.whiteColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(
                Icons.star_rate,
                size: 20.w,
                color: UiConstants.yellowColor,
              ),
              SizedBox(width: 8.w),
              Text(
                LocaleKeys.kTextReviews.tr(),
                style: UiConstants.textStyle2.copyWith(
                  color: UiConstants.whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${reviews.length} ${LocaleKeys.kTextReviews.tr()}',
                style: UiConstants.textStyle5.copyWith(
                  color: UiConstants.whiteColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Reviews List or Empty State
          if (reviews.isEmpty)
            _buildEmptyState(context, LocaleKeys.kTextNoReviewsAvailable.tr())
          else
            ...reviews
                .map((review) => _buildReviewItem(context, review))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, QuestReview review) {
    return Container(
      margin: getMarginOrPadding(bottom: 16),
      padding: getMarginOrPadding(all: 12),
      decoration: BoxDecoration(
        color: UiConstants.whiteColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: UiConstants.whiteColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info and Rating
          Row(
            children: [
              // User Avatar
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: UiConstants.blueColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : 'U',
                    style: UiConstants.textStyle5.copyWith(
                      color: UiConstants.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // User Name and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: UiConstants.textStyle5.copyWith(
                        color: UiConstants.whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      review.createdAt,
                      style: UiConstants.textStyle6.copyWith(
                        color: UiConstants.whiteColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Rating Stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 16.w,
                    color: UiConstants.yellowColor,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Review Text
          Text(
            review.text,
            style: UiConstants.textStyle5.copyWith(
              color: UiConstants.whiteColor.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      padding: getMarginOrPadding(all: 16),
      child: Column(
        children: [
          Icon(
            Icons.star_outline,
            size: 48.w,
            color: UiConstants.whiteColor.withValues(alpha: 0.3),
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: UiConstants.textStyle5.copyWith(
              color: UiConstants.whiteColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
