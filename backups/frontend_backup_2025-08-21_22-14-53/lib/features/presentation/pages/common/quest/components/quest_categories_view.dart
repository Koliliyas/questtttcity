import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/components/quest_category_chip.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class QuestCategoriesView extends StatelessWidget {
  final MainPreferences preferences;
  final int reward;
  final String vehicle;
  const QuestCategoriesView(
      {super.key,
      required this.preferences,
      required this.reward,
      required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return BlurryContainer(
      blur: 15,
      borderRadius: BorderRadius.circular(24.r),
      padding: EdgeInsets.zero,
      child: GradientCard(
        borderRadius: 24.r,
        contentPadding:
            getMarginOrPadding(top: 9, bottom: 9, right: 12, left: 12),
        body: Wrap(
          runSpacing: 7.w,
          spacing: 7.w,
          children: [
            QuestCategoryChip(title: "$reward credits"),
            QuestCategoryChip(
                title:
                    '${preferences.timeframe} ${LocaleKeys.kTextHour.tr().toLowerCase()}'),
            QuestCategoryChip(
                title:
                    '${preferences.milege} ${LocaleKeys.kTextMiles.tr().toLowerCase()}'),
            QuestCategoryChip(title: vehicle),
            QuestCategoryChip(title: preferences.level),
          ],
        ),
      ),
    );
  }
}

