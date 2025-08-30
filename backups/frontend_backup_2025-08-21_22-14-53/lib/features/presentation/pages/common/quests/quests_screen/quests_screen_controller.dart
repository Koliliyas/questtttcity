import 'dart:math';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_bottom_sheet_template/custom_bottom_sheet_template.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/components/quest_chip.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/components/quests_screen_filter_body/quests_screen_filter_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/cubit/quests_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class QuestsScreenController {
  static showFilterSheet(BuildContext context, QuestsScreenCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        // РІС‹С‡РёС‚Р°РµРј РІС‹СЃРѕС‚Сѓ toolbar, С‚РµРєСЃС‚РѕРІРѕРіРѕ РїРѕР»СЏ (57.h),
        // РѕС‚СЃС‚СѓРїР° РѕС‚ toolbar (24.h) Рё РѕС‚СЃС‚СѓРїР° РѕС‚
        // С‚РµРєСЃС‚РѕРІРѕРіРѕ РїРѕР»СЏ (11.h)
        height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 92.h,
        isBack: false,
        buttonText: LocaleKeys.kTextFindQuests.tr(),
        onTapButton: () {
          cubit.searchFilter();
        },
        buttonHasGradient: false,
        body: QuestsScreenFilterBody(
          selectedIndexes: (cubit.state as QuestsScreenLoaded).selectedIndexes,
          onTap: cubit.onTapSubcategory,
          onResetFilter: cubit.onResetFilter,
        ),
      ),
    );
  }

  static List<Widget> getQuestCardChips(
      QuestItemStatus? questItemStatus, int index, bool isFavorite) {
    List<Widget> chips = [];
    if (questItemStatus == QuestItemStatus.ALL) {
      switch (index % 3) {
        case 0:
          chips.addAll([getCompleteChip(), SizedBox(width: 11.w), getFavoriteChip(isFavorite)]);
          break;
        case 1:
          chips.addAll([getActiveChip(), SizedBox(width: 11.w), getFavoriteChip(isFavorite)]);
          break;
        case 2:
          chips.addAll([getFavoriteChip(isFavorite)]);
          break;
        default:
      }
    } else if (questItemStatus == QuestItemStatus.ACTIVE) {
      chips.addAll([getActiveChip(), SizedBox(width: 11.w), getFavoriteChip(isFavorite)]);
    } else if (questItemStatus == QuestItemStatus.COMPLETED) {
      chips.addAll([getCompleteChip()]);
    } else {
      chips.addAll([getFavoriteChip(isFavorite)]);
    }
    return chips;
  }

  static Widget getFavoriteChip(bool isFavorite) {
    return QuestChip(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_outline,
        color: UiConstants.redColor,
      ),
      onTap: () {},
    );
  }

  static Widget getActiveChip() {
    return QuestChip(
      chipColor: UiConstants.yellowColor,
      icon: Transform.rotate(
        angle: 25 * pi / 180,
        child: Transform.flip(
          flipX: true,
          child: const Icon(Icons.replay_outlined, color: UiConstants.whiteColor),
        ),
      ),
      onTap: () {},
    );
  }

  static Widget getCompleteChip() {
    return QuestChip(
      chipColor: UiConstants.greenColor,
      icon: const Icon(Icons.check, color: UiConstants.whiteColor),
      onTap: () {},
    );
  }
}

enum QuestItemStatus { ALL, ACTIVE, COMPLETED, FAVORRITE }

