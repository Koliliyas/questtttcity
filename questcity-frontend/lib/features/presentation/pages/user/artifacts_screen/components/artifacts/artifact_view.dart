import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

class ArtifactView extends StatelessWidget {
  const ArtifactView({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      height: 385.h,
      contentPadding: getMarginOrPadding(all: 16),
      borderRadius: 24.r,
      hasBlur: true,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Image.asset(image, fit: BoxFit.cover),
              ),
              SizedBox(width: 10.w),
              const CustomButton(
                  title: 'Hollywood',
                  textColor: UiConstants.black2Color,
                  buttonColor: UiConstants.whiteColor),
            ],
          ),
        ],
      ),
    );
  }
}

enum FileType { image, video, doc }
