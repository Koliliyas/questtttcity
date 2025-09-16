import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(const Locale('en'));

  Future<void> changeLanguage(BuildContext context, Locale locale) async {
    await EasyLocalization.of(context)?.setLocale(locale);
    emit(locale);
  }
}
