import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton(
      {super.key,
      required this.title,
      required this.onTap,
      required this.icon});

  final String title;
  final Function() onTap;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: getMarginOrPadding(top: 6, bottom: 6, left: 8, right: 8),
        decoration: BoxDecoration(
          color: UiConstants.whiteColor.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(title,
                  style: UiConstants.textStyle10
                      .copyWith(color: UiConstants.whiteColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
