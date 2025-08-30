import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/features/presentation/widgets/quest_preferences/quest_preference_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';

class MainPreferencesBody extends StatelessWidget {
  const MainPreferencesBody(
      {super.key,
      required this.preference,
      required this.selectedPrefIndexes,
      required this.onTap});

  final List<QuestPreference> preference;
  final List<List<int>> selectedPrefIndexes;
  final Function(int preferencesIndex, int preferencesItemIndex,
      {int? preferencesSubItemIndex, bool preferencesItemHasSubitems}) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          List<int> preferenceIndexes = selectedPrefIndexes[index];
          int checkedItemIndex = preferenceIndexes.first;
          int? checkedSubIndex =
              preferenceIndexes.length > 1 ? preferenceIndexes[1] : null;
          return QuestPreferenceView(
              title: preference[index].title,
              preferenceIndex: index,
              preferencesItems: preference[index].items,
              checkedItemIndex: checkedItemIndex,
              checkedSubIndex: checkedSubIndex,
              onTap: onTap);
        },
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemCount: preference.length);
  }
}
