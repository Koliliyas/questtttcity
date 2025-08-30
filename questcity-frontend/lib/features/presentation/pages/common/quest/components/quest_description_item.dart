import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_model.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class QuestDescriptionItem extends StatelessWidget {
  final QuestPoint point;
  const QuestDescriptionItem({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      hasBlur: true,
      contentPadding: getMarginOrPadding(all: 10),
      body: Column(
        children: [
          Text(
            point.name,
            style: UiConstants.textStyle5.copyWith(color: UiConstants.whiteColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '3 ${LocaleKeys.kTextMiles.tr().toLowerCase()}',
                style: UiConstants.textStyle2.copyWith(color: UiConstants.lightOrangeColor),
              ),
              SizedBox(width: 10.w),
              Text(
                '10 ${LocaleKeys.kTextPoints.tr().toLowerCase()}',
                style: UiConstants.textStyle2.copyWith(color: UiConstants.lightOrangeColor),
              ),
            ],
          ),
          Padding(
            padding: getMarginOrPadding(top: 12, bottom: 12),
            child: const Divider(color: UiConstants.darkViolet2Color),
          ),
          Expanded(
            child: Text(point.description,
                style: UiConstants.textStyle20.copyWith(color: UiConstants.whiteColor),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

