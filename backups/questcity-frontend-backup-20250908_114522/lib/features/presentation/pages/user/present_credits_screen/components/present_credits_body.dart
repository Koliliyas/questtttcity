import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/settings_screen_controller.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class PresentCreditsBody extends StatefulWidget {
  const PresentCreditsBody(
      {super.key, required this.onButtonTap, required this.creditsAction});

  final CreditsActions creditsAction;
  final Function(int creditCount) onButtonTap;

  @override
  State<PresentCreditsBody> createState() => _PresentCreditsBodyState();
}

class _PresentCreditsBodyState extends State<PresentCreditsBody> {
  final TextEditingController _creditController = TextEditingController(text: '100');
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (widget.creditsAction == CreditsActions.BUY ? 294 : 334) - 100,
      child: Form(
        key: formKey,
        child: Column(
          children: [
            if (widget.creditsAction != CreditsActions.BUY)
              Padding(
                padding: getMarginOrPadding(bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25.w,
                      child: ClipOval(
                        child: Image.asset(
                          Paths.avatarPath,
                          fit: BoxFit.cover,
                          width: 50.w,
                          height: 50.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Tomas Andersen',
                      style: UiConstants.textStyle4
                          .copyWith(color: UiConstants.whiteColor),
                    ),
                  ],
                ),
              ),
            CustomTextField(
              hintText: LocaleKeys.kTextCreditsCount.tr(),
              controller: _creditController,
              keyboardType: TextInputType.number,
              isExpanded: true,
              textStyle: UiConstants.textStyle12
                  .copyWith(color: UiConstants.blackColor),
              fillColor: UiConstants.whiteColor,
              isTextFieldInBottomSheet: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 2.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '1 credit = \$1',
                style: UiConstants.textStyle13
                    .copyWith(color: UiConstants.whiteColor),
              ),
            ),
            const Spacer(),
            CustomButton(
              title: widget.creditsAction == CreditsActions.BUY
                  ? 'Next'
                  : LocaleKeys.kTextPresent.tr(),
              onTap: _creditController.text.isNotEmpty
                  ? () => widget.onButtonTap(int.parse(_creditController.text))
                  : null,
            ),
            SizedBox(height: 23.h),
          ],
        ),
      ),
    );
  }
}

