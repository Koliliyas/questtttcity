import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class ToolItemCountParts extends StatelessWidget {
  const ToolItemCountParts({super.key, required this.collectedParts});

  final int collectedParts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getMarginOrPadding(all: 7),
      decoration: BoxDecoration(
        color: UiConstants.whiteColor,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Text(
        _getRomanNumeral(),
        style: UiConstants.textStyle25.copyWith(color: UiConstants.black2Color),
      ),
    );
  }

  String _getRomanNumeral() {
    switch (collectedParts) {
      case 1:
        return 'I/III';
      case 2:
        return 'II/III';
      case 3:
        return 'III/III';
      default:
        return 'I/III';
    }
  }
}
