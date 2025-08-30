import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class ToolbarCircleRing extends StatelessWidget {
  const ToolbarCircleRing(
      {super.key, required this.height, required this.opacity});

  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: UiConstants.whiteColor.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
