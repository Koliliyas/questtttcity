import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';
import 'package:los_angeles_quest/features/presentation/widgets/quest_preferences/quest_preference_view_item.dart';

class QuestPreferenceView extends StatefulWidget {
  const QuestPreferenceView(
      {super.key,
      required this.title,
      required this.preferencesItems,
      required this.checkedItemIndex,
      required this.onTap,
      required this.preferenceIndex,
      this.checkedSubIndex,
      this.isExpanded,
      this.onTapExpanded});

  final int preferenceIndex;
  final String? title;
  final List<QuestPreferenceItem> preferencesItems;
  final int checkedItemIndex;
  final int? checkedSubIndex;
  final Function(int preferencesIndex, int preferencesItemIndex,
      {int? preferencesSubItemIndex, bool preferencesItemHasSubitems}) onTap;
  final bool? isExpanded;
  final Function()? onTapExpanded;

  @override
  State<QuestPreferenceView> createState() => _QuestPreferenceViewState();
}

class _QuestPreferenceViewState extends State<QuestPreferenceView> {
  bool? isExpanded;

  @override
  void initState() {
    isExpanded = widget.isExpanded;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Visibility(
              visible: widget.title != null,
              child: Padding(
                padding: getMarginOrPadding(bottom: 12),
                child: Text(
                  widget.title ?? '',
                  style: UiConstants.textStyle8
                      .copyWith(color: UiConstants.whiteColor),
                ),
              ),
            ),
            if (isExpanded != null)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    isExpanded = !(isExpanded ?? false);
                    widget.onTapExpanded!();
                  }),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        LocaleKeys.kTextAll.tr(),
                        style: UiConstants.registration.copyWith(
                          color: UiConstants.whiteColor.withValues(alpha: .69),
                        ),
                      ),
                      Icon(
                        size: 25.w,
                        isExpanded == true
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: UiConstants.whiteColor.withValues(alpha: .69),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
        Visibility(
          visible: isExpanded != false,
          child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return QuestPreferenceViewItem(
                    preferenceIndex: widget.preferenceIndex,
                    preferencesItem: index < widget.preferencesItems.length
                        ? widget.preferencesItems[index]
                        : widget.preferencesItems.first,
                    isChecked: widget.checkedItemIndex == index,
                    checkedSubIndex: widget.checkedSubIndex,
                    index: index,
                    onTap: widget.onTap);
              },
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemCount: widget.preferencesItems.length),
        ),
      ],
    );
  }
}

