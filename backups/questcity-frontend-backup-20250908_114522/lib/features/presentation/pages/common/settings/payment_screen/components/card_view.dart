import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

class CardView extends StatelessWidget {
  const CardView(
      {super.key,
      required this.backgroundImage,
      this.height,
      this.isChecked,
      this.onTap});

  final String backgroundImage;
  final double? height;
  final bool? isChecked;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GradientCard(
          onTap: onTap,
          height: height ?? 120.h,
          contentPadding: getMarginOrPadding(all: 16),
          contentMargin: isChecked != null ? getMarginOrPadding(top: 12) : null,
          backgroundImage: backgroundImage,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Image.asset(Paths.visa2IconPath),
              ),
              Text(
                '**** **** **** 1458',
                style: UiConstants.textStyle4
                    .copyWith(color: UiConstants.whiteColor),
              ),
            ],
          ),
        ),
        if (isChecked == true)
          Positioned(
              top: 0,
              right: 0,
              child: SvgPicture.asset(Paths.ckeckInCircleIconPath))
      ],
    );
  }
}
