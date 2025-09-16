import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class SupportChatTextField extends StatelessWidget {
  const SupportChatTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      textStyle:
          UiConstants.textStyle13.copyWith(color: UiConstants.whiteColor),
      contentPadding: getMarginOrPadding(top: 0),
      isExpanded: true,
      hintText: "${LocaleKeys.kTextTextMessage.tr()}...",
      controller: TextEditingController(),
      fillColor: UiConstants.darkVioletColor,
      suffixWidget: SvgPicture.asset(
        Paths.sentIconPath,
        height: 28.w,
        width: 28.w,
        colorFilter: const ColorFilter.mode(UiConstants.whiteColor, BlendMode.srcIn),
      ),
      prefixWidget: Transform.rotate(
        angle: 45 * (3.14 / 180),
        child: const Icon(Icons.attach_file, color: UiConstants.whiteColor),
      ),
    );
  }
}

