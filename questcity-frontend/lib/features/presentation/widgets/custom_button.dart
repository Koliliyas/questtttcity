import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onTap,
    required this.title,
    this.height = 60,
    this.isFilled = true,
    this.isActive = true,
    this.iconRight,
    this.iconLeft,
    this.buttonColor,
    this.textColor,
    this.textPadding,
    this.borderRadius,
    this.textStyle,
    this.width,
    this.hasGradient = true,
  });

  final void Function()? onTap;
  final String title;
  final double height;
  final double? width;
  final bool isFilled;
  final bool isActive;
  final Widget? iconRight;
  final Widget? iconLeft;
  final Color? buttonColor;
  final Color? textColor;
  final EdgeInsets? textPadding;
  final double? borderRadius;
  final TextStyle? textStyle;
  final bool hasGradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isActive ? onTap : null,
      child: Container(
        padding: textPadding ?? getMarginOrPadding(left: 19, right: 19),
        height: height.h,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
            color: isFilled
                ? isActive
                    ? buttonColor ?? UiConstants.orangeColor
                    : UiConstants.orangeColor
                : Colors.transparent,
            borderRadius: BorderRadius.all(
              Radius.circular(borderRadius ?? 63.r),
            ),
            border: isFilled && hasGradient
                ? GradientBoxBorder(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.white.withValues(alpha: .3)],
                    ),
                    width: 1,
                  )
                : null),
        //border:
        //    isFilled ? Border.all(color: UiConstants.borderColor) : null),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconLeft != null
                ? Padding(
                    padding: getMarginOrPadding(right: 10),
                    child: iconLeft,
                  )
                : Container(),
            Text(
              title,
              style: (textStyle ?? UiConstants.textStyle5).copyWith(
                  color: isFilled
                      ? (textColor ?? UiConstants.whiteColor)
                          .withValues(alpha: isActive ? 1 : .5)
                      : UiConstants.whiteColor),
            ),
            iconRight != null
                ? Padding(
                    padding: getMarginOrPadding(left: 10),
                    child: iconRight,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
