import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';

class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      title: LocaleKeys.kTextDelete.tr(),
      buttonColor: UiConstants.redColor,
      onTap: onTap,
      hasGradient: true,
      iconLeft: Icon(Icons.delete, color: UiConstants.whiteColor, size: 24.w),
    );
  }
}

