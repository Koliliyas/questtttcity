import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/l10n/l10n.dart';

class LanguageBody extends StatefulWidget {
  const LanguageBody({super.key, required this.onChangeLocale});

  final Function(Locale locale) onChangeLocale;

  @override
  State<LanguageBody> createState() => _LanguageBodyState();
}

class _LanguageBodyState extends State<LanguageBody> {
  Locale? locale;

  @override
  void initState() {
    //locale = context.locale;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    locale = context.locale;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LanguageBodyItem(
            isChecked: (locale ?? context.locale) == L10n.all[0],
            text: LocaleKeys.kTextEnglish.tr(),
            onTap: () {
              setState(() {
                locale = L10n.all[0];
              });
              widget.onChangeLocale(L10n.all[0]);
            }),
        SizedBox(height: 12.h),
        LanguageBodyItem(
            isChecked: (locale ?? context.locale) == L10n.all[1],
            text: LocaleKeys.kTextSpanish.tr(),
            onTap: () {
              setState(() {
                locale = L10n.all[1];
              });
              widget.onChangeLocale(L10n.all[1]);
            }),
      ],
    );
  }
}

class LanguageBodyItem extends StatelessWidget {
  const LanguageBodyItem(
      {super.key,
      required this.isChecked,
      required this.text,
      required this.onTap});

  final bool isChecked;
  final String text;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      onTap: onTap,
      height: 65.h,
      contentPadding: getMarginOrPadding(all: 16),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isChecked)
            Padding(
              padding: getMarginOrPadding(right: 20),
              child: SvgPicture.asset(Paths.ckeckInCircleIconPath,
                  width: 24.w, height: 24.w),
            ),
          Text(
            text,
            style:
                UiConstants.textStyle7.copyWith(color: UiConstants.whiteColor),
          ),
        ],
      ),
    );
  }
}

