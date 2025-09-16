import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/cubit/quest_detail_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class QuestDetailPointsSection extends StatelessWidget {
  final List<QuestPoint> points;

  const QuestDetailPointsSection({
    super.key,
    required this.points,
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
                Icons.location_on,
                size: 20.w,
                color: UiConstants.whiteColor,
              ),
              SizedBox(width: 8.w),
              Text(
                LocaleKeys.kTextPoints.tr(),
                style: UiConstants.textStyle2.copyWith(
                  color: UiConstants.whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Points List or Empty State
          if (points.isEmpty)
            _buildEmptyState(context, LocaleKeys.kTextNoPointsAvailable.tr())
          else
            ...points.asMap().entries.map((entry) {
              final index = entry.key;
              final point = entry.value;
              final isLast = index == points.length - 1;

              return _buildPointItem(context, point, index + 1, isLast);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildPointItem(
    BuildContext context,
    QuestPoint point,
    int pointNumber,
    bool isLast,
  ) {
    return Container(
      margin: getMarginOrPadding(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Point Number and Line
          Column(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: _getPointColor(point.type),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: UiConstants.whiteColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    pointNumber.toString(),
                    style: UiConstants.textStyle5.copyWith(
                      color: UiConstants.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40.h,
                  color: UiConstants.whiteColor.withValues(alpha: 0.3),
                ),
            ],
          ),

          SizedBox(width: 12.w),

          // Point Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Point Type Badge
                Container(
                  padding: getMarginOrPadding(
                    left: 8,
                    right: 8,
                    top: 4,
                    bottom: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPointColor(point.type).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _getPointColor(point.type),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getPointTypeText(point.type),
                    style: UiConstants.textStyle6.copyWith(
                      color: _getPointColor(point.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                // Point Name
                Text(
                  point.name,
                  style: UiConstants.textStyle4.copyWith(
                    color: UiConstants.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),

                // Point Description
                Text(
                  point.description,
                  style: UiConstants.textStyle5.copyWith(
                    color: UiConstants.whiteColor.withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),

                // Coordinates (if needed for debugging)
                if (point.latitude != 0 && point.longitude != 0)
                  Text(
                    '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
                    style: UiConstants.textStyle6.copyWith(
                      color: UiConstants.whiteColor.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),

          // Point Image
          if (point.image.isNotEmpty)
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
                  point.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: UiConstants.grayColor,
                      child: Icon(
                        Icons.location_on,
                        size: 24.w,
                        color: UiConstants.whiteColor.withValues(alpha: 0.5),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getPointColor(String type) {
    switch (type.toLowerCase()) {
      case 'start':
        return UiConstants.greenColor;
      case 'end':
        return UiConstants.redColor;
      case 'halfway':
        return UiConstants.blueColor;
      default:
        return UiConstants.grayColor;
    }
  }

  String _getPointTypeText(String type) {
    switch (type.toLowerCase()) {
      case 'start':
        return LocaleKeys.kTextStartPoint.tr();
      case 'end':
        return LocaleKeys.kTextFinishPoint.tr();
      case 'halfway':
        return LocaleKeys.kTextHalfwayPoint.tr();
      default:
        return type;
    }
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      padding: getMarginOrPadding(all: 16),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
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
