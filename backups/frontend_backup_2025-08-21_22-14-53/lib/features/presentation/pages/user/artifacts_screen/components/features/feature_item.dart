import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/forward_button.dart';

class FeatureItem extends StatelessWidget {
  const FeatureItem(
      {super.key,
      required this.image,
      required this.title,
      required this.onTap});

  final String image;
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(child: Image.asset(image)),
          SizedBox(width: 10.w),
          Text(
            title,
            style:
                UiConstants.textStyle4.copyWith(color: UiConstants.whiteColor),
          ),
          const Spacer(),
          ForwardButton(onTap: onTap)
        ],
      ),
    );
  }
}
