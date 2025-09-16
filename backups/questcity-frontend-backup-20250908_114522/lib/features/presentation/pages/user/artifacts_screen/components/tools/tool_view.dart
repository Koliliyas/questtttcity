import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/tools/tool_item.dart';

class ToolView extends StatelessWidget {
  const ToolView(
      {super.key,
      required this.image,
      required this.title,
      required this.collectedParts});

  final String image;
  final String title;
  final int collectedParts;

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
              Wrap(
                runSpacing: 10.w,
                spacing: 10.w,
                children: List.generate(
                  3,
                  (index) => SizedBox(
                    height: 97.w,
                    width: 97.w,
                    child: ToolItem(
                        collectedParts: index + 1,
                        showCollectedIcon: false,
                        image: image,
                        title: title,
                        onTap: () {}),
                  ),
                ),
              ),
            ],
          ),
          if (collectedParts == 3)
            Positioned(
              right: 0,
              top: 0,
              child: SvgPicture.asset(Paths.checkInCircleIconPath,
                  height: 36.w, width: 36.w),
            )
        ],
      ),
    );
  }
}

enum FileType { image, video, doc }
