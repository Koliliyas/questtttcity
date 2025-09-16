import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/see_a_map_screen.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class QuestSeeMapView extends StatelessWidget {
  final List<QuestPoint> points;
  final String questName;
  final List<MerchItem> merchItem;
  final int questId;
  final String mileage;
  final String questImage;
  const QuestSeeMapView(
      {super.key,
      required this.questId,
      required this.points,
      required this.questName,
      required this.merchItem,
      required this.mileage,
      required this.questImage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        FadeInRoute(
            SeeAMapScreen(
              merchItem: merchItem,
              questImage: questImage,
              route: points,
              questName: questName,
              questId: questId,
              mileage: mileage,
            ),
            Routes.seeMapScreen),
      ),
      child: Container(
        padding: getMarginOrPadding(top: 7, bottom: 7, left: 20, right: 10),
        decoration: BoxDecoration(
          color: UiConstants.purpleColor,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          children: [
            Text(
              LocaleKeys.kTextSeeMap.tr(),
              style: UiConstants.textStyle2.copyWith(color: UiConstants.whiteColor),
            ),
            SizedBox(width: 5.w),
            Icon(Icons.keyboard_arrow_right_rounded, color: UiConstants.whiteColor, size: 25.w),
          ],
        ),
      ),
    );
  }
}

