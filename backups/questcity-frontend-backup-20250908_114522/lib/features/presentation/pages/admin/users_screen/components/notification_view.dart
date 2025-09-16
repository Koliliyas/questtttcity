import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: badges.Badge(
        badgeStyle: badges.BadgeStyle(
          badgeColor: UiConstants.greenColor,
          padding: getMarginOrPadding(all: 3),
        ),
        position: badges.BadgePosition.topEnd(end: -8, top: -7),
        badgeContent: Text(
          '99',
          style: UiConstants.textStyle1
              .copyWith(color: UiConstants.darkGreenColor),
        ),
        child: const Icon(Icons.notifications, color: UiConstants.whiteColor),
      ),
    );
  }
}
