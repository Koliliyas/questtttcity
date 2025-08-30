
import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/data/models/quests/current_quest_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/current_activity_screen.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';


class RightNowView extends StatelessWidget {
  final QuestPointModel model;
  final int questId;
  final int point;
  const RightNowView({super.key, required this.model, required this.questId, required this.point});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CurrentActivityScreen(
                        activityType: model,
                        questId: questId,
                        point: point,
                      )));
        },
        child: Row(
          children: [
            const Spacer(),
            Container(
              padding: getMarginOrPadding(left: 10, right: 10, top: 4, bottom: 4),
              decoration: BoxDecoration(
                border: Border.all(color: UiConstants.black2Color),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Text(
                LocaleKeys.kTextRightNow.tr(),
                style: UiConstants.textStyle24.copyWith(color: UiConstants.black2Color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

