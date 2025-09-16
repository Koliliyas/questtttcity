import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

class QuestEditDropdownItem extends StatefulWidget {
  const QuestEditDropdownItem(
      {super.key,
      required this.title,
      this.isRequired = true,
      required this.body,
      this.isChecked = false,
      this.collapsedIconColor,
      this.canExpanded = true});

  final String title;
  final bool isRequired;
  final bool isChecked;
  final Widget body;
  final Color? collapsedIconColor;
  final bool canExpanded;

  @override
  State<QuestEditDropdownItem> createState() => _QuestEditDropdownItemState();
}

class _QuestEditDropdownItemState extends State<QuestEditDropdownItem> {
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GradientCard(
          borderRadius: 24.r,
          onTap: widget.canExpanded
              ? () => setState(() => isVisible = !isVisible)
              : null,
          contentPadding:
              getMarginOrPadding(left: 16, right: 16, top: 14, bottom: 14),
          body: Column(
            children: [
              Row(
                children: [
                  Text(
                    widget.title,
                    style: UiConstants.textStyle7
                        .copyWith(color: UiConstants.whiteColor),
                  ),
                  Visibility(
                    visible: widget.isChecked,
                    child: Padding(
                      padding: getMarginOrPadding(left: 16),
                      child: SvgPicture.asset(Paths.checkInCircleIconPath,
                          height: 24.w, width: 24.w),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: widget.canExpanded
                        ? () => setState(() => isVisible = !isVisible)
                        : null,
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                          color: isVisible && widget.isRequired
                              ? UiConstants.lightViolet2Color
                              : widget.collapsedIconColor ??
                                  UiConstants.whiteColor.withValues(alpha: .46),
                          shape: BoxShape.circle),
                      child: Icon(
                          widget.isRequired
                              ? isVisible
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded
                              : isVisible
                                  ? Icons.close_rounded
                                  : Icons.add_rounded,
                          size: 30.w,
                          color: UiConstants.whiteColor),
                    ),
                  ),
                ],
              ),
              Visibility(
                  visible: !widget.isRequired && isVisible,
                  child: Padding(
                      padding: getMarginOrPadding(top: 12, bottom: 6),
                      child: widget.body))
            ],
          ),
        ),
        if (widget.isRequired)
          Visibility(
              visible: isVisible,
              child: Padding(
                  padding: getMarginOrPadding(top: 12), child: widget.body))
      ],
    );
  }
}
