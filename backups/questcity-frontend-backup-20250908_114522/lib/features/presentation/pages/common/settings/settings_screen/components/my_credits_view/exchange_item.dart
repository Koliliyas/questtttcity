import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

class ExchangeItem extends StatelessWidget {
  const ExchangeItem(
      {super.key, this.isChecked, this.onTap, required this.creditsCount});

  final bool? isChecked;
  final Function()? onTap;
  final int creditsCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GradientCard(
          onTap: onTap,
          contentMargin: getMarginOrPadding(top: 12),
          body: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.asset(
                  Paths.quest2Path,
                  fit: BoxFit.cover,
                  width: 50.w,
                  height: 50.w,
                ),
              ),
              SizedBox(width: 13.w),
              Text(
                'Hollywood Hills',
                style: UiConstants.textStyle4
                    .copyWith(color: UiConstants.whiteColor, fontSize: 18.sp),
              ),
              const Spacer(),
              Text(
                creditsCount.toString(),
                style: UiConstants.textStyle4
                    .copyWith(color: UiConstants.orangeColor, fontSize: 18.sp),
              ),
            ],
          ),
        ),
        if (isChecked == true)
          Positioned(
              top: 0,
              right: 0,
              child: SvgPicture.asset(Paths.checkInCircleIconPath))
      ],
    );
  }
}
