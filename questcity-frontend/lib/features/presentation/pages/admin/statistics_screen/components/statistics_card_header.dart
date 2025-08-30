import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

class StatisticsCardHeader extends StatelessWidget {
  const StatisticsCardHeader(
      {super.key,
      required this.onExpandedOrCollapsed,
      this.isDropdown = false,
      this.isExpanded = true,
      this.isCategoryCard = false});

  final bool isCategoryCard;

  final bool isDropdown;
  final Function() onExpandedOrCollapsed;

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          isDropdown ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50.w,
          child: isDropdown || !isCategoryCard
              ? GradientCard(
                  height: 50.w,
                  backgroundImage: Paths.quest1Path,
                  body: Container(),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Image.asset(Paths.category1Path,
                      height: 50.w, fit: BoxFit.cover),
                ),
        ),
        SizedBox(width: 9.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isDropdown)
                Padding(
                  padding: getMarginOrPadding(bottom: 2),
                  child: Text(
                    LocaleKeys.kTextCategory.tr(),
                    style: UiConstants.textStyle22.copyWith(
                        color: UiConstants.lightViolet2Color.withValues(alpha: .58),
                        fontWeight: FontWeight.w500),
                  ),
                ),
              Text(isDropdown ? 'Hollywood Hills' : 'Detective',
                  style: UiConstants.textStyle4
                      .copyWith(color: UiConstants.whiteColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (isDropdown)
          Expanded(
            child: SizedBox(
              height: 50.w,
              child: Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: onExpandedOrCollapsed,
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                          color: isExpanded
                              ? UiConstants.lightViolet2Color
                              : UiConstants.whiteColor.withValues(alpha: .46),
                          shape: BoxShape.circle),
                      child: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 30.w,
                          color: UiConstants.whiteColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

