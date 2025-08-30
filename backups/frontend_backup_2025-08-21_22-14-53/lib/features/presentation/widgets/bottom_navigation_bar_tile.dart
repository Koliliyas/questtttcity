import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/getwidget.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class BottomNavigationBarTile extends StatelessWidget {
  const BottomNavigationBarTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
    this.countChatMessage,
  });

  final String icon;
  final VoidCallback onTap;
  final String title;
  final bool isActive;
  final int? countChatMessage;

  @override
  Widget build(BuildContext context) {
    final colorActive =
        isActive ? UiConstants.orangeColor : UiConstants.whiteColor;
    final colorDisactive =
        !isActive ? UiConstants.orangeColor : UiConstants.whiteColor;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            countChatMessage != null && countChatMessage != 0
                ? GFIconBadge(
                    counterChild: GFBadge(
                      color: colorDisactive,
                      shape: GFBadgeShape.circle,
                      child: Text(
                        countChatMessage.toString(),
                        style: UiConstants.textStyle17
                            .copyWith(color: colorActive, height: 1),
                      ),
                    ),
                    child: SvgPicture.asset(icon,
                        height: 24.w, 
                        colorFilter: ColorFilter.mode(colorActive, BlendMode.srcIn)),
                  )
                : SvgPicture.asset(
                    icon,
                    height: 24.w,
                    colorFilter: ColorFilter.mode(colorActive, BlendMode.srcIn),
                  ),
            Text(
              title,
              style: UiConstants.textStyle1
                  .copyWith(color: colorActive, fontSize: 11.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
