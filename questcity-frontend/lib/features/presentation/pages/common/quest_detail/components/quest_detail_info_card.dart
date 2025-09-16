import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_list_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_detail/cubit/quest_detail_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class QuestDetailInfoCard extends StatelessWidget {
  final QuestItem questItem;
  final QuestDetails? questDetails;

  const QuestDetailInfoCard({
    super.key,
    required this.questItem,
    this.questDetails,
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
          Text(
            LocaleKeys.kTextQuestDetails.tr(),
            style: UiConstants.textStyle2.copyWith(
              color: UiConstants.whiteColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // Info Grid
          _buildInfoGrid(context),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    return Column(
      children: [
        // First Row
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                LocaleKeys.kTextDifficulty.tr(),
                _getDifficultyText(questItem.mainPreferences.level),
                Icons.trending_up,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildInfoItem(
                context,
                LocaleKeys.kTextDuration.tr(),
                _getTimeframeText(questItem.mainPreferences.timeframe),
                Icons.access_time,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Second Row
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                LocaleKeys.kTextGroupType.tr(),
                _getGroupTypeText(questItem.mainPreferences.group),
                Icons.group,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildInfoItem(
                context,
                LocaleKeys.kTextMileage.tr(),
                _getMileageText(questItem.mainPreferences.milege),
                Icons.location_on,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Third Row
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                LocaleKeys.kTextPrice.tr(),
                _getPriceText(),
                Icons.attach_money,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildInfoItem(
                context,
                LocaleKeys.kTextCredits.tr(),
                "${questDetails?.credits.cost ?? 0} / ${questDetails?.credits.reward ?? 0}",
                Icons.stars,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
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
          Row(
            children: [
              Icon(
                icon,
                size: 16.w,
                color: UiConstants.whiteColor.withValues(alpha: 0.7),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: UiConstants.textStyle5.copyWith(
                    color: UiConstants.whiteColor.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: UiConstants.textStyle4.copyWith(
              color: UiConstants.whiteColor,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return LocaleKeys.kTextEasy.tr();
      case 'intermediate':
        return LocaleKeys.kTextMedium.tr();
      case 'advanced':
        return LocaleKeys.kTextHard.tr();
      case 'expert':
        return 'Expert';
      default:
        return level;
    }
  }

  String _getTimeframeText(int? timeframe) {
    if (timeframe == null) return LocaleKeys.kTextUnlimited.tr();

    switch (timeframe) {
      case 1:
        return LocaleKeys.kTextOneDay.tr();
      case 7:
        return '1 Week';
      case 30:
        return '1 Month';
      default:
        return '$timeframe days';
    }
  }

  String _getGroupTypeText(int? group) {
    if (group == null) return 'Any';

    switch (group) {
      case 1:
        return 'Single';
      case 2:
        return 'Couple';
      case 3:
        return 'Family';
      case 4:
        return 'Friends';
      default:
        return 'Group $group';
    }
  }

  String _getMileageText(String mileage) {
    switch (mileage.toLowerCase()) {
      case 'local':
        return 'Local';
      case 'nearby':
        return 'Nearby';
      case 'faraway':
        return 'Far Away';
      case '5-10':
        return '5-10 km';
      case '10-30':
        return '10-30 km';
      case '30-100':
        return '30-100 km';
      case '>100':
        return '>100 km';
      default:
        return mileage;
    }
  }

  String _getPriceText() {
    if (questItem.mainPreferences.price.amount == null ||
        questItem.mainPreferences.price.amount == 0) {
      return LocaleKeys.kTextFree.tr();
    }

    if (questItem.mainPreferences.price.isSubscription == true) {
      return LocaleKeys.kTextSubscription.tr();
    }

    return '\$${questItem.mainPreferences.price.amount}';
  }
}
