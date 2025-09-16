import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class EditButton extends StatelessWidget {
  const EditButton({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 53.w,
        height: 53.w,
        decoration: const BoxDecoration(
            color: UiConstants.whiteColor, shape: BoxShape.circle),
        padding: getMarginOrPadding(all: 12),
        child: SvgPicture.asset(Paths.pencilIconPath),
      ),
    );
  }
}
