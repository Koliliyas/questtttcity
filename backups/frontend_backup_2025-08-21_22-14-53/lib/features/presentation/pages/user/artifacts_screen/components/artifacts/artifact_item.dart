import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class ArtifactItem extends StatelessWidget {
  const ArtifactItem(
      {super.key,
      required this.image,
      required this.isCollected,
      required this.onTap});

  final String image;
  final bool isCollected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: UiConstants.blackColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(image, fit: BoxFit.cover, height: double.infinity),
              if (isCollected)
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: UiConstants.black2Color.withValues(alpha: .44),
                  child: Icon(Icons.lock,
                      color: UiConstants.whiteColor, size: 24.w),
                ),
              Positioned(
                top: 5.w,
                right: 5.w,
                child: SvgPicture.asset(Paths.checkInCircleIconPath),
              )
            ],
          ),
        ),
      ),
    );
  }
}
