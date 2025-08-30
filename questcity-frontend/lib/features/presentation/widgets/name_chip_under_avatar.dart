import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';

class NameChipUnderAvatar extends StatelessWidget {
  const NameChipUnderAvatar({super.key, this.role});

  final Role? role;

  @override
  Widget build(BuildContext context) {
    return BlurryContainer(
      blur: 7,
      borderRadius: BorderRadius.circular(24.r),
      padding: EdgeInsets.zero,
      child: GradientCard(
        borderRadius: 24.r,
        contentPadding:
            getMarginOrPadding(top: 7, bottom: 7, right: 12, left: 12),
        body: Text(
            role == Role.MANAGER
                ? LocaleKeys.kTextManager.tr()
                : role == Role.USER
                    ? LocaleKeys.kTextUser.tr()
                    : role == Role.ADMIN
                        ? 'Admin' // TODO: translate
                        : LocaleKeys.kTextNewUser.tr(),
            style:
                UiConstants.textStyle2.copyWith(color: UiConstants.whiteColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

