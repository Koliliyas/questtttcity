import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class LanguageItem extends StatelessWidget {
  const LanguageItem(
      {super.key,
      required this.title,
      required this.isSelected,
      required this.onTap});

  final String title;
  final bool isSelected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        padding: getMarginOrPadding(left: 5, right: 20),
        decoration: BoxDecoration(
          color: UiConstants.whiteColor,
          borderRadius: BorderRadius.circular(63.r),
        ),
        child: Row(
          children: [
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(4.r),
                  ),
                ),
                value: isSelected,
                activeColor: UiConstants.purpleColor,
                onChanged: (bool? newValue) => onTap(),
                side: WidgetStateBorderSide.resolveWith(
                  (states) => const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                fillColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return UiConstants.purpleColor;
                    }
                    return UiConstants.lightPinkColor;
                  },
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style:
                  UiConstants.textField.copyWith(color: UiConstants.blackColor),
            ),
          ],
        ),
      ),
    );
  }
}
