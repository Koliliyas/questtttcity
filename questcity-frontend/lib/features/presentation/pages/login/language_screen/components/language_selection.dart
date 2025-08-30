import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/core/language_cubit/language_cubit_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/language_screen/components/language_item.dart';
import 'package:los_angeles_quest/l10n/l10n.dart';

class LanguageSelection extends StatefulWidget {
  const LanguageSelection({super.key});

  @override
  State<LanguageSelection> createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LanguageItem(
          title: LocaleKeys.kTextEnglish.tr(),
          isSelected: context.locale == L10n.all[0],
          onTap: () async {
            context.read<LanguageCubit>().changeLanguage(context, L10n.all[0]);
          },
        ),
        SizedBox(height: 14.h),
        LanguageItem(
          title: LocaleKeys.kTextSpanish.tr(),
          isSelected: context.locale == L10n.all[1],
          onTap: () async {
            context.read<LanguageCubit>().changeLanguage(context, L10n.all[1]);
          },
        ),
      ],
    );
  }
}

