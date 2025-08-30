import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/core/constants/app_colors.dart';
import 'package:los_angeles_quest/core/constants/app_text_styles.dart';
import 'package:los_angeles_quest/l10n/l10n.dart';

class EmptyStatisticsView extends StatelessWidget {
  const EmptyStatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 64.w,
            color: AppColors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            context.l10n.noStatisticsAvailable,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
