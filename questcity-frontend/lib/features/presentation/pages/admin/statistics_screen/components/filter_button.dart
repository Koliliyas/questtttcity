import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/components/badge/gf_badge.dart';
import 'package:getwidget/components/badge/gf_icon_badge.dart';
import 'package:getwidget/position/gf_badge_position.dart';
import 'package:getwidget/shape/gf_badge_shape.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class FilterButtonWithCounter extends StatelessWidget {
  const FilterButtonWithCounter(
      {super.key, required this.onTap, required this.countFilters});

  final Function() onTap;
  final int countFilters;

  @override
  Widget build(BuildContext context) {
    return countFilters != 0
        ? GFIconBadge(
            padding: EdgeInsets.zero,
            position: GFBadgePosition.topEnd(end: 0),
            counterChild: GFBadge(
              size: GFSize.LARGE,
              color: UiConstants.greenColor,
              shape: GFBadgeShape.circle,
              child: Text(
                countFilters.toString(),
                style: UiConstants.textStyle1
                    .copyWith(color: UiConstants.darkGreenColor, height: 1),
              ),
            ),
            child: FilterButton(onTap: onTap),
          )
        : FilterButton(onTap: onTap);
  }
}

class FilterButton extends StatelessWidget {
  const FilterButton({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: getMarginOrPadding(all: 10),
        width: 58.w,
        height: 58.w,
        decoration: const BoxDecoration(
            color: UiConstants.darkVioletColor, shape: BoxShape.circle),
        child: SvgPicture.asset(Paths.filtersIconPath),
      ),
    );
  }
}
