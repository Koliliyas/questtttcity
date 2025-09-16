import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/tools/tool_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/cubit/artifacts_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class ToolsView extends StatelessWidget {
  const ToolsView({super.key, required this.onTap});

  final Function(ArtifactsViewType artifactsViewType,
      {String title, String image, int collectedParts}) onTap;

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      Paths.toolbarArtifacts,
      Paths.artifactRangefinderIcon,
      Paths.artifactEcholocationScreenIcon,
      Paths.artifactCompassIcon,
      Paths.artifactCameraIcon,
      Paths.artifactBeepingRadarIcon,
      Paths.artifactQrScannerIcon,
      Paths.artifactOrbitalRadarIcon,
      Paths.artifactBinoculusIcon
    ];
    List<String> titles = [
      LocaleKeys.kTextRangefinder.tr(),
      LocaleKeys.kTextRangefinder.tr(),
      LocaleKeys.kTextEcholocationScreen.tr(),
      LocaleKeys.kTextTargetCompass.tr(),
      LocaleKeys.kTextCameraTool.tr(),
      LocaleKeys.kTextBeepingRadar.tr(),
      LocaleKeys.kTextQRScanner.tr(),
      LocaleKeys.kTextOrbitalRadar.tr(),
      LocaleKeys.kTextScreenIllustrationDescriptor.tr()
    ];

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
          itemCount: 9,
          itemBuilder: (context, index) {
            String image = images[index];
            String title = titles[index];
            int collectedParts = index % 4;
            return ToolItem(
              image: image,
              title: title,
              collectedParts: index % 4,
              onTap: () => onTap(ArtifactsViewType.tool,
                  title: title, image: image, collectedParts: collectedParts),
            );
          }),
    );
  }
}

enum FileType { image, video, doc }

