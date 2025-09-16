import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/cubit/quest_detail_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class QuestDetailMerchandiseSection extends StatelessWidget {
  final List<QuestMerchandise> merchandise;

  const QuestDetailMerchandiseSection({
    super.key,
    required this.merchandise,
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
                Icons.shopping_bag,
                size: 20.w,
                color: UiConstants.whiteColor,
              ),
              SizedBox(width: 8.w),
              Text(
                LocaleKeys.kTextMerchandise.tr(),
                style: UiConstants.textStyle2.copyWith(
                  color: UiConstants.whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Merchandise List or Empty State
          if (merchandise.isEmpty)
            _buildEmptyState(
                context, LocaleKeys.kTextNoMerchandiseAvailable.tr())
          else
            ...merchandise
                .map((item) => _buildMerchandiseItem(context, item))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildMerchandiseItem(BuildContext context, QuestMerchandise item) {
    return Container(
      margin: getMarginOrPadding(bottom: 12),
      padding: getMarginOrPadding(all: 12),
      decoration: BoxDecoration(
        color: UiConstants.whiteColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: UiConstants.whiteColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Item Image
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: UiConstants.whiteColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: UiConstants.grayColor,
                    child: Icon(
                      Icons.shopping_bag,
                      size: 24.w,
                      color: UiConstants.whiteColor.withValues(alpha: 0.5),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Name
                Text(
                  item.name,
                  style: UiConstants.textStyle4.copyWith(
                    color: UiConstants.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),

                // Item Description
                Text(
                  item.description,
                  style: UiConstants.textStyle5.copyWith(
                    color: UiConstants.whiteColor.withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),

                // Price
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16.w,
                      color: UiConstants.greenColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '\$${item.price}',
                      style: UiConstants.textStyle4.copyWith(
                        color: UiConstants.greenColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Buy Button
          Container(
            padding: getMarginOrPadding(
              left: 12,
              right: 12,
              top: 6,
              bottom: 6,
            ),
            decoration: BoxDecoration(
              color: UiConstants.greenColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: UiConstants.greenColor,
                width: 1,
              ),
            ),
            child: Text(
              'Buy',
              style: UiConstants.textStyle5.copyWith(
                color: UiConstants.greenColor,
                fontWeight: FontWeight.w600,
              ),
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
            Icons.shopping_bag_outlined,
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
