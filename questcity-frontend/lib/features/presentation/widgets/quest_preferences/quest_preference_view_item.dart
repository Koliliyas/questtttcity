import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';

class QuestPreferenceViewItem extends StatefulWidget {
  const QuestPreferenceViewItem(
      {super.key,
      required this.preferencesItem,
      required this.isChecked,
      required this.onTap,
      required this.index,
      required this.preferenceIndex,
      this.checkedSubIndex,
      this.isSubPreferences = false,
      this.padding = EdgeInsets.zero});

  final int preferenceIndex;
  final int? checkedSubIndex;
  final bool isSubPreferences;
  final QuestPreferenceItem preferencesItem;
  final bool isChecked;
  final int index;
  final Function(int preferencesIndex, int preferencesItemIndex,
      {int? preferencesSubItemIndex, bool preferencesItemHasSubitems}) onTap;
  final EdgeInsets padding;

  @override
  State<QuestPreferenceViewItem> createState() =>
      _QuestPreferenceViewItemState();
}

class _QuestPreferenceViewItemState extends State<QuestPreferenceViewItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: widget.padding,
          child: Row(
            children: [
              Transform.scale(
                scale: 1.2.w,
                child: SizedBox(
                  height: 24.w,
                  width: 24.w,
                  child: Checkbox(
                    checkColor: UiConstants.whiteColor, // Цвет галочки
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      // Цвет фона в зависимости от состояния
                      if (states.contains(WidgetState.selected)) {
                        // Состояние включено
                        return UiConstants.greenColor;
                      }
                      return Colors.transparent; // Состояние выключено
                    }),
                    shape: const CircleBorder(),
                    side:
                        const BorderSide(color: UiConstants.lightViolet2Color),
                    value: widget.isChecked,
                    onChanged: (value) {
                      setState(() {
                        widget.onTap(widget.preferenceIndex,
                            value == false ? -1 : widget.index,
                            preferencesSubItemIndex: widget.isSubPreferences
                                ? widget.checkedSubIndex
                                : null,
                            preferencesItemHasSubitems:
                                widget.preferencesItem.subitems?.subitems !=
                                    null);
                      });
                    },
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  padding: getMarginOrPadding(
                      top: 6, bottom: 6, left: 12, right: 12),
                  decoration: BoxDecoration(
                    color: widget.isChecked
                        ? UiConstants.whiteColor
                        : UiConstants.purpleColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      if (widget.preferencesItem.image != null)
                        Padding(
                          padding: getMarginOrPadding(right: 10),
                          child: Image.asset(widget.preferencesItem.image ?? '',
                              width: 60.w, height: 60.w),
                        ),
                      Expanded(
                        child: Text(
                          widget.preferencesItem.title,
                          style: UiConstants.textStyle7.copyWith(
                              color: widget.isChecked
                                  ? UiConstants.purpleColor
                                  : UiConstants.whiteColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.preferencesItem.textFieldEntry != null)
          Visibility(
            // если пункт не выбран, то и текстовое поле не показывается, если isVisibleTextFieldWhenCheckedParent = true
            visible: widget.preferencesItem.textFieldEntry
                        ?.isVisibleTextFieldWhenCheckedParent ==
                    true
                ? widget.isChecked
                : true,
            child: Padding(
              padding: getMarginOrPadding(left: 36, top: 12),
              child: CustomTextField(
                isShowError: false,
                height: 40.h,
                borderRadius: 12.r,
                contentPadding: getMarginOrPadding(left: 12, right: 12),
                hintText: widget.preferencesItem.textFieldEntry!.hint,
                controller: widget.preferencesItem.textFieldEntry!.controller,
                keyboardType:
                    widget.preferencesItem.textFieldEntry!.keyboardType,
                fillColor: UiConstants.whiteColor,
                textStyle: UiConstants.textStyle7
                    .copyWith(color: UiConstants.purpleColor),
                textColor: UiConstants.purpleColor,
                isExpanded: true,
                isEnabled: widget.isChecked,
                validator: widget.preferencesItem.textFieldEntry!.validator ??
                    (value) => Utils.validate(value),
                inputFormatters:
                    widget.preferencesItem.textFieldEntry!.inputFormatters,
                prefixText: widget.preferencesItem.textFieldEntry!.prefixText,
              ),
            ),
          ),
        if (widget.preferencesItem.subitems != null)
          Visibility(
            // если пункт не выбран, то и поднастройки не показываются, если isVisibleWhenCheckedParent = true
            visible:
                widget.preferencesItem.subitems?.isVisibleWhenCheckedParent ==
                        true
                    ? widget.isChecked
                    : true,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: (MediaQuery.of(context).size.width - 32.w - 36.w),
                padding: getMarginOrPadding(top: 12.h),
                child: Wrap(
                  spacing: 17.w,
                  runSpacing: 12.h,
                  children: List.generate(
                    widget.preferencesItem.subitems!.subitems.length,
                    (index) {
                      QuestPreferenceSubItem? subitems =
                          widget.preferencesItem.subitems;
                      double? subitemsBetweenPadding =
                          widget.preferencesItem.subitems?.subitems.length == 3
                              ? 17.w
                              : 10.w;
                      // ширина минус боковые оступы, отступы между элементами и оступ в подсписке
                      double? subitemsWidth = subitems!.isHorizontalDirection
                          ? (MediaQuery.of(context).size.width -
                                  32.w -
                                  (subitemsBetweenPadding *
                                      subitems.subitems.length) -
                                  36.w) /
                              (subitems.subitems.length)
                          : null;
                      return SizedBox(
                        width: subitemsWidth,
                        child: QuestPreferenceViewItem(
                          preferenceIndex: widget.preferenceIndex,
                          preferencesItem: index < subitems.subitems.length
                              ? QuestPreferenceItem(subitems.subitems[index])
                              : QuestPreferenceItem(subitems.subitems.first),
                          isChecked: widget.checkedSubIndex == index,
                          onTap: widget.onTap,
                          index: widget.index,
                          isSubPreferences: true,
                          checkedSubIndex: index,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
