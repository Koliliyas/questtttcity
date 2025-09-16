import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_list_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/components/quest_item.dart';

class QuestsView extends StatelessWidget {
  const QuestsView(
      {super.key,
      this.padding,
      required this.questItems,
      this.isScrollable = false,
      this.canEdit = false});

  final EdgeInsets? padding;
  final bool isScrollable;
  final bool canEdit;
  final QuestListModel questItems;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        physics: isScrollable ? null : const NeverScrollableScrollPhysics(),
        padding: padding ?? getMarginOrPadding(left: 16, right: 16),
        shrinkWrap: true,
        itemBuilder: (context, index) =>
            QuestItemWidget(questItem: questItems.items[index], canEdit: canEdit),
        separatorBuilder: (context, index) => SizedBox(height: 14.h),
        itemCount: questItems.items.length);
  }
}
