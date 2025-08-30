import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/tools/tool_item_count_parts.dart';

class ToolItem extends StatelessWidget {
  const ToolItem(
      {super.key,
      required this.collectedParts,
      required this.image,
      required this.title,
      required this.onTap,
      this.showCollectedIcon = true});

  final String image;
  final String title;
  final int collectedParts;
  final bool showCollectedIcon;
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
              if (collectedParts == 0)
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: UiConstants.black2Color.withValues(alpha: .44),
                  child: Icon(Icons.lock,
                      color: UiConstants.whiteColor, size: 24.w),
                ),
              if (collectedParts != 0)
                Positioned(
                  top: 5.w,
                  right: 5.w,
                  child: collectedParts == 3 && showCollectedIcon
                      ? SvgPicture.asset(Paths.checkInCircleIconPath)
                      : ToolItemCountParts(collectedParts: collectedParts),
                )
            ],
          ),
        ),
      ),
    );
  }
}
