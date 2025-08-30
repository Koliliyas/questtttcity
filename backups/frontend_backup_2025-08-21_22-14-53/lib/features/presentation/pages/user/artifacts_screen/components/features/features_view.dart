import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/features/feature_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/cubit/artifacts_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class FeaturesView extends StatelessWidget {
  const FeaturesView({super.key, required this.onTap});

  final Function(ArtifactsViewType artifactsViewType) onTap;

  @override
  Widget build(BuildContext context) {
    List<String> artifactNames = [
      LocaleKeys.kTextFiles.tr(),
      LocaleKeys.kTextToolParts.tr(),
      LocaleKeys.kTextCollectedArtifacts.tr()
    ];
    List<String> artifactImages = [
      Paths.files,
      Paths.artifactRangefinderIcon,
      Paths.artifactWordLockerIcon
    ];
    List<ArtifactsViewType> artifactTypes = [
      ArtifactsViewType.files,
      ArtifactsViewType.tools,
      ArtifactsViewType.artifacts
    ];

    return GradientCard(
      contentPadding: getMarginOrPadding(all: 16),
      borderRadius: 24.r,
      hasBlur: true,
      body: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => FeatureItem(
                image: artifactImages[index],
                title: artifactNames[index],
                onTap: () => onTap(artifactTypes[index]),
              ),
          separatorBuilder: (context, index) => Padding(
                padding: getMarginOrPadding(top: 8, bottom: 8),
                child: Divider(
                  color: UiConstants.whiteColor.withValues(alpha: .29),
                ),
              ),
          itemCount: 3),
    );
  }
}

