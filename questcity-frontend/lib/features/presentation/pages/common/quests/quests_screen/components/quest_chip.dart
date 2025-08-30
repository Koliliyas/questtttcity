import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class QuestChip extends StatelessWidget {
  const QuestChip(
      {super.key, this.chipColor, required this.icon, required this.onTap});

  final Color? chipColor;
  final Widget icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 37.w,
        width: 37.w,
        decoration: BoxDecoration(
            color: chipColor ?? UiConstants.whiteColor.withValues(alpha: .32),
            shape: BoxShape.circle),
        child: icon,
      ),
    );
  }
}
