import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58.w,
        width: 58.w,
        decoration: BoxDecoration(
          color: UiConstants.purpleColor,
          borderRadius: BorderRadius.circular(63.r),
        ),
        child: const Icon(
          Icons.favorite,
          color: UiConstants.redColor,
        ),
      ),
    );
  }
}
