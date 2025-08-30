import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:badges/badges.dart' as badges;

class ToolbarItem extends StatelessWidget {
  const ToolbarItem({
    super.key,
    required this.iconPath,
    this.countMessage,
    required this.onTap,
    required this.title,
    required this.size,
    required this.textPadding,
  });

  final String iconPath;
  final String title;
  final double size;
  final double textPadding;
  final int? countMessage;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: badges.Badge(
        badgeStyle: badges.BadgeStyle(
          badgeColor: countMessage != null
              ? UiConstants.greenColor
              : Colors.transparent,
          padding: getMarginOrPadding(all: 6),
        ),
        position: badges.BadgePosition.topEnd(end: 30.w, top: 30.w),
        badgeContent: countMessage != null
            ? Text(
                '2',
                style: UiConstants.textStyle1
                    .copyWith(color: UiConstants.darkGreenColor),
              )
            : null,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Image.asset(iconPath, width: size, height: size),
            Positioned(
              bottom: textPadding,
              child: Text(
                title,
                style: UiConstants.textStyle1
                    .copyWith(color: UiConstants.whiteColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
