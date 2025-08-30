import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class FilterView extends StatelessWidget {
  const FilterView(
      {super.key,
      required this.onTap,
      required this.isVisible,
      required this.countSelectedFilters});

  final Function() onTap;
  final bool isVisible;
  final int countSelectedFilters;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: GestureDetector(
        onTap: onTap,
        child: badges.Badge(
          showBadge: countSelectedFilters != 0,
          badgeStyle: badges.BadgeStyle(
            badgeColor: UiConstants.greenColor,
            padding: getMarginOrPadding(all: 6),
          ),
          position: badges.BadgePosition.topEnd(end: 2, top: -7),
          badgeContent: Text(countSelectedFilters.toString(),
              style: UiConstants.textStyle1),
          child: SvgPicture.asset(
            Paths.filtersIconPath,
          ),
        ),
      ),
    );
  }
}
