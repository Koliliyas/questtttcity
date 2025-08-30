import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/artifacts/artifact_item.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/cubit/artifacts_screen_cubit.dart';

class ArtifactsView extends StatelessWidget {
  const ArtifactsView({super.key, required this.onTap});

  final Function(ArtifactsViewType artifactsViewType,
      {String image, bool isCollected}) onTap;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      height: 385.h,
      contentPadding: getMarginOrPadding(all: 16),
      borderRadius: 24.r,
      hasBlur: true,
      body: GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.w,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            bool isCollected = index % 2 == 0;
            bool isHidden = index % 4 == 0;
            String image = !isHidden
                ? Paths.wordLockerHidden
                : [
                    Paths.artifactWordLockerIcon,
                    Paths.wordLockerHidden
                  ][index % 2];

            return ArtifactItem(
              image: image,
              isCollected: index % 2 == 0,
              onTap: () => onTap(ArtifactsViewType.artifact,
                  isCollected: isCollected, image: image),
            );
          }),
    );
  }
}

enum FileType { image, video, doc }
