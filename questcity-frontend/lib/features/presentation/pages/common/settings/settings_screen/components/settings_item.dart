import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

class SettingsItem extends StatelessWidget {
  const SettingsItem({super.key, required this.title, required this.onTap});

  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      borderRadius: 26.r,
      onTap: onTap,
      contentPadding:
          getMarginOrPadding(top: 18.5, bottom: 18.5, right: 16, left: 16),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style:
                UiConstants.textStyle11.copyWith(color: UiConstants.whiteColor),
          ),
          Image.asset(Paths.arrowForwardInCircleIconPath)
        ],
      ),
    );
  }
}
