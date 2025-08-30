import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class HintButton extends StatelessWidget {
  const HintButton({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 53.w,
        height: 53.w,
        decoration: const BoxDecoration(
            color: UiConstants.grayColor, shape: BoxShape.circle),
        child: Image.asset(Paths.toolbarHints),
      ),
    );
  }
}
