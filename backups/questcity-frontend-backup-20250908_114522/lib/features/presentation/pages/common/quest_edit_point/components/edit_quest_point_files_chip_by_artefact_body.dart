import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/quest_preferences/quest_preference_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/components/quest_edit_dropdown_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class EditQuestPointFilesChipByArtefactBody extends StatelessWidget {
  const EditQuestPointFilesChipByArtefactBody(
      {super.key,
      required this.onTap,
      required this.items,
      required this.selectedIndexes,
      this.title});

  final String? title;
  final List<QuestPreferenceItem> items;
  final List<List<int>> selectedIndexes;
  final Function(int, int,
      {bool preferencesItemHasSubitems, int? preferencesSubItemIndex}) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuestEditDropdownItem(
          title: LocaleKeys.kTextTools.tr(),
          body: QuestPreferenceView(
              title: title,
              preferencesItems: items,
              checkedItemIndex:
                  selectedIndexes.isNotEmpty && selectedIndexes[0].isNotEmpty
                      ? selectedIndexes[0].first
                      : 0,
              checkedSubIndex:
                  selectedIndexes.isNotEmpty && selectedIndexes[0].isNotEmpty
                      ? selectedIndexes[0].last
                      : 0,
              onTap: onTap,
              preferenceIndex: 0),
        ),
        SizedBox(height: 12.h),
        QuestEditDropdownItem(
          title: LocaleKeys.kTextAddFile.tr(),
          isRequired: false,
          canExpanded: false,
          collapsedIconColor: UiConstants.greenColor,
          body: Container(),
        ),
      ],
    );
  }
}

