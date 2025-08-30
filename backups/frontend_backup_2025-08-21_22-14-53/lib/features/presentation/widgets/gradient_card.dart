import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class GradientCard extends StatelessWidget {
  const GradientCard(
      {super.key,
      required this.body,
      this.height,
      this.width,
      this.contentPadding,
      this.contentMargin,
      this.borderRadius,
      this.onTap,
      this.backgroundImage,
      this.hasBlur = false,
      this.blur,
      this.shape,
      this.color,
      this.beginGradient,
      this.endGradient});

  final Widget body;
  final double? height;
  final double? width;
  final EdgeInsets? contentPadding;
  final EdgeInsets? contentMargin;
  final double? borderRadius;
  final Function()? onTap;
  final String? backgroundImage;
  final bool hasBlur;
  final double? blur;
  final BoxShape? shape;
  final Color? color;
  final Alignment? beginGradient;
  final Alignment? endGradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BlurryContainer(
        blur: hasBlur ? blur ?? 15 : 0,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(borderRadius ?? 19.r),
        child: Container(
          width: width,
          height: height,
          padding: contentPadding ??
              getMarginOrPadding(right: 11, left: 11, top: 9, bottom: 9),
          margin: contentMargin,
          decoration: BoxDecoration(
            color: color ?? UiConstants.whiteColor.withValues(alpha: .16),
            border: GradientBoxBorder(
              gradient: LinearGradient(
                begin: beginGradient ?? Alignment.topLeft,
                end: endGradient ?? Alignment.bottomRight,
                colors: [Colors.white, Colors.white.withValues(alpha: .3)],
              ),
              width: 1.2,
            ),
            borderRadius: shape == null
                ? BorderRadius.circular(borderRadius ?? 19.r)
                : null,
            shape: shape ?? BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                  color: UiConstants.black2Color.withValues(alpha: .25),
                  offset: Offset(0, 2.h),
                  blurRadius: 24.3.r),
            ],
            image: backgroundImage != null
                ? DecorationImage(
                    image: AssetImage(backgroundImage ?? ''),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high)
                : null,
          ),
          child: body,
        ),
      ),
    );
  }
}
