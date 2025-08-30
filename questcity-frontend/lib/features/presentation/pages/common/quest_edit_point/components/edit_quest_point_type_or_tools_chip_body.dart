import 'package:flutter/material.dart';
import 'package:los_angeles_quest/features/presentation/widgets/quest_preferences/quest_preference_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';

class EditQuestPointTypeOrToolsChipBody extends StatelessWidget {
  const EditQuestPointTypeOrToolsChipBody({
    super.key,
    required this.onTap,
    required this.items,
    required this.selectedIndexes,
    required this.title,
  });

  final String title;
  final List<QuestPreferenceItem> items;
  final List<List<int>> selectedIndexes;
  final Function(int, int,
      {bool preferencesItemHasSubitems, int? preferencesSubItemIndex}) onTap;

  @override
  Widget build(BuildContext context) {
    return QuestPreferenceView(
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
        preferenceIndex: 0);
  }
}
