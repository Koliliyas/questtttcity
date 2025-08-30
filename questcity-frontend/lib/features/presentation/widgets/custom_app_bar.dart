import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar(
      {super.key, required this.onTapBack, required this.title, this.action});

  final Function() onTapBack;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onTapBack,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 53.w,
                    width: 53.w,
                    decoration: BoxDecoration(
                        color: UiConstants.whiteColor.withValues(alpha: .5),
                        shape: BoxShape.circle),
                    child: Icon(Icons.keyboard_backspace,
                        color: UiConstants.whiteColor, size: 30.w),
                  ),
                ),
              ),
            ),
            action ?? Container(),
          ],
        ),
        Padding(
          padding: getMarginOrPadding(left: 65, right: 65),
          child: Text(
            title,
            style:
                UiConstants.textStyle9.copyWith(color: UiConstants.whiteColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
