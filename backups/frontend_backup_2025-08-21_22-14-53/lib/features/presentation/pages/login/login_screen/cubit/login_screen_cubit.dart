import 'dart:async';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/params/authentification_param.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/features/domain/entities/person_entity.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/auth_login.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/get_verification_code.dart';
import 'package:los_angeles_quest/features/domain/usecases/person/get_me.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/home_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/enter_the_code_screen/enter_the_code_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:los_angeles_quest/features/presentation/bloc/auth_new/auth_cubit.dart';
import 'package:los_angeles_quest/features/presentation/bloc/auth_new/auth_event.dart';
import 'package:los_angeles_quest/features/presentation/bloc/auth_new/auth_state.dart';
import 'package:los_angeles_quest/utils/logger.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';

part 'login_screen_state.dart';

class LoginScreenCubit extends Cubit<LoginScreenState> {
  final AuthLogin authLogin;
  final AuthRepository repository;
  final GetMe getMe;
  final GetVerificationCode getVerificationCode;
  final SharedPreferences sharedPreferences;
  final FirebaseMessaging firebaseMessaging;
  final AuthNewCubit authNewCubit; // РќРѕРІР°СЏ СЃРёСЃС‚РµРјР°
  StreamSubscription?
      _authSubscription; // РџРѕРґРїРёСЃРєР° РЅР° СЃРѕСЃС‚РѕСЏРЅРёРµ РЅРѕРІРѕР№ СЃРёСЃС‚РµРјС‹

  LoginScreenCubit(
      {required this.authLogin,
      required this.getMe,
      required this.repository,
      required this.getVerificationCode,
      required this.sharedPreferences,
      required this.firebaseMessaging,
      required this.authNewCubit})
      : super(const LoginScreenInitial()) {
    bool isRememberUser =
        sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser) ??
            false;

    emit(LoginScreenInitial(rememberUser: isRememberUser));
  }

  TextEditingController emailController =
      TextEditingController(); // kirillmaximov.di@gmail.com // admin@admin.app
  TextEditingController passwordController =
      TextEditingController(); // 12311231 // 12345678

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future login(BuildContext context) async {
    appLogger.d('рџ"Ќ DEBUG: Login button pressed');
    appLogger.d('рџ"Ќ DEBUG: Email: ${emailController.text}');
    appLogger.d(
        'рџ"Ќ DEBUG: Password: ${passwordController.text.length} characters');

    // 1. Р­РјРёС‚РёРј СЃРѕСЃС‚РѕСЏРЅРёРµ Р·Р°РіСЂСѓР·РєРё
    emit(LoginScreenLoading(message: LocaleKeys.kTextAuthorization.tr()));

    try {
      // РћС‚РјРµРЅСЏРµРј РїСЂРµРґС‹РґСѓС‰СѓСЋ РїРѕРґРїРёСЃРєСѓ, РµСЃР»Рё РѕРЅР° РµСЃС‚СЊ
      await _authSubscription?.cancel();

      // РСЃРїРѕР»СЊР·СѓРµРј РЅРѕРІСѓСЋ СЃРёСЃС‚РµРјСѓ Р°СѓС‚РµРЅС‚РёС„РёРєР°С†РёРё
      authNewCubit.add(AuthNewLoginRequested(
        email: emailController.text,
        password: passwordController.text,
      ));

      // РЎР»СѓС€Р°РµРј СЃРѕСЃС‚РѕСЏРЅРёРµ РЅРѕРІРѕР№ СЃРёСЃС‚РµРјС‹
      _authSubscription = authNewCubit.stream.listen((authState) {
        if (authState is AuthNewLoading) {
          appLogger.d(
              'рџ”Ќ DEBUG: AuthNewLoading received, keeping LoginScreenLoading');
          // РћСЃС‚Р°РІР»СЏРµРј LoginScreenLoading СЃРѕСЃС‚РѕСЏРЅРёРµ
        } else if (authState is AuthNewLoginSuccess) {
          appLogger.d('рџ”Ќ DEBUG: Login successful, getting user data');
          getMeData(context);
        } else if (authState is AuthNewError) {
          appLogger
              .d('рџ"Ќ DEBUG: Login failed with error: ${authState.message}');
          emit(LoginScreenInitial(
              rememberUser: sharedPreferences
                      .getBool(SharedPreferencesKeys.isRememberUser) ??
                  false));

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authState.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else if (authState is AuthNewNetworkError) {
          appLogger.d('рџ”Ќ DEBUG: Network error: ${authState.message}');
          emit(LoginScreenInitial(
              rememberUser: sharedPreferences
                      .getBool(SharedPreferencesKeys.isRememberUser) ??
                  false));

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('РћС€РёР±РєР° СЃРµС‚Рё: ${authState.message}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else if (authState is AuthNewTimeoutError) {
          appLogger.d('рџ”Ќ DEBUG: Timeout error: ${authState.message}');
          emit(LoginScreenInitial(
              rememberUser: sharedPreferences
                      .getBool(SharedPreferencesKeys.isRememberUser) ??
                  false));

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('РўР°Р№РјР°СѓС‚: ${authState.message}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else if (authState is AuthNewInitial) {
          appLogger
              .d('рџ”Ќ DEBUG: AuthNewInitial received, keeping current state');
          // РћСЃС‚Р°РІР»СЏРµРј С‚РµРєСѓС‰РµРµ СЃРѕСЃС‚РѕСЏРЅРёРµ
        } else {
          appLogger
              .d('рџ”Ќ DEBUG: Unhandled auth state: ${authState.runtimeType}');
          // Р”Р»СЏ РЅРµРѕР±СЂР°Р±РѕС‚Р°РЅРЅС‹С… СЃРѕСЃС‚РѕСЏРЅРёР№ РІРѕР·РІСЂР°С‰Р°РµРјСЃСЏ Рє РЅР°С‡Р°Р»СЊРЅРѕРјСѓ
          emit(LoginScreenInitial(
              rememberUser: sharedPreferences
                      .getBool(SharedPreferencesKeys.isRememberUser) ??
                  false));
        }
      });
    } catch (e) {
      appLogger.e('рџ”Ќ DEBUG: Unexpected error during login: $e');
      emit(LoginScreenInitial(
          rememberUser:
              sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser) ??
                  false));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('РќРµРѕР¶РёРґР°РЅРЅР°СЏ РѕС€РёР±РєР°: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future getMeData(BuildContext context) async {
    try {
      final failureOrPerson = await getMe(NoParams());

      return failureOrPerson.fold(
        (error) async {
          print('рџ”Ќ DEBUG: GetMe failed with error: $error');
          emit(LoginScreenInitial(
              rememberUser: sharedPreferences
                      .getBool(SharedPreferencesKeys.isRememberUser) ??
                  false));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_mapFailureToMessage(error)),
            ),
          );
        },
        (person) async {
          print('рџ”Ќ DEBUG: GetMe successful, navigating to home');

          emit(LoginScreenLoaded(person: person));

          // РЎРѕС…СЂР°РЅСЏРµРј СЃРѕСЃС‚РѕСЏРЅРёРµ "Р·Р°РїРѕРјРЅРёС‚СЊ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ"
          if (state is LoginScreenLoaded) {
            final loadedState = state as LoginScreenLoaded;
            await sharedPreferences.setBool(
                SharedPreferencesKeys.isRememberUser, loadedState.rememberUser);
          }

          // РџРµСЂРµС…РѕРґРёРј РЅР° РіР»Р°РІРЅС‹Р№ СЌРєСЂР°РЅ
          Navigator.pushReplacement(
            context,
            FadeInRoute(
              const HomeScreen(),
              Routes.homeScreen,
              arguments: {
                'role': Utils.convertServerRoleToEnumItem(person.role),
                'username': person.username
              },
            ),
          );
        },
      );
    } catch (e) {
      print('рџ”Ќ DEBUG: Unexpected error in getMeData: $e');
      emit(LoginScreenInitial(
          rememberUser:
              sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser) ??
                  false));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'РћС€РёР±РєР° РїРѕР»СѓС‡РµРЅРёСЏ РґР°РЅРЅС‹С… РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future getVerifyCode(BuildContext context) async {
    try {
      final failureOrCode = await getVerificationCode(
        AuthenticationParams(
            email: emailController.text,
            password: passwordController.text,
            fbid: await firebaseMessaging.getToken()),
      );

      return failureOrCode.fold(
        (error) async {
          print('рџ”Ќ DEBUG: GetVerificationCode failed with error: $error');
          emit(LoginScreenInitial(
              rememberUser: sharedPreferences
                      .getBool(SharedPreferencesKeys.isRememberUser) ??
                  false));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_mapFailureToMessage(error)),
            ),
          );
        },
        (_) async {
          print(
              'рџ”Ќ DEBUG: GetVerificationCode successful, navigating to code screen');
          Navigator.push(
            context,
            FadeInRoute(
              const EnterTheCodeScreen(),
              Routes.enterTheCodeScreen,
              arguments: {
                'email': emailController.text,
                'password': passwordController.text,
              },
            ),
          );
        },
      );
    } catch (e) {
      print('рџ”Ќ DEBUG: Unexpected error in getVerifyCode: $e');
      emit(LoginScreenInitial(
          rememberUser:
              sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser) ??
                  false));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'РћС€РёР±РєР° РїРѕР»СѓС‡РµРЅРёСЏ РєРѕРґР° РІРµСЂРёС„РёРєР°С†РёРё: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void toggleRememberUser() {
    if (state is LoginScreenLoaded) {
      final currentState = state as LoginScreenLoaded;
      emit(currentState.copyWith(rememberUser: !currentState.rememberUser));
    } else if (state is LoginScreenInitial) {
      final currentState = state as LoginScreenInitial;
      emit(currentState.copyWith(rememberUser: !currentState.rememberUser));
    }
  }

  void validateFields() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final isEmailValid = email.isNotEmpty && Utils.emailRegex.hasMatch(email);
    final isPasswordValid = password.length >= 6;

    final allFieldsValidate = isEmailValid && isPasswordValid;

    if (state is LoginScreenLoaded) {
      final currentState = state as LoginScreenLoaded;
      emit(currentState.copyWith(
        isEmailValid: isEmailValid,
        isPasswordValid: isPasswordValid,
        allFieldsValidate: allFieldsValidate,
      ));
    } else if (state is LoginScreenInitial) {
      final currentState = state as LoginScreenInitial;
      emit(currentState.copyWith(
        isEmailValid: isEmailValid,
        isPasswordValid: isPasswordValid,
        allFieldsValidate: allFieldsValidate,
      ));
    }
  }

  void onTextChanged() {
    validateFields();
  }

  void onChangeRememberUser() {
    toggleRememberUser();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'РћС€РёР±РєР° СЃРµСЂРІРµСЂР°. РџРѕРїСЂРѕР±СѓР№С‚Рµ РїРѕР·Р¶Рµ.';
      case ConnectionFailure:
        return 'РћС€РёР±РєР° РїРѕРґРєР»СЋС‡РµРЅРёСЏ. РџСЂРѕРІРµСЂСЊС‚Рµ РёРЅС‚РµСЂРЅРµС‚.';
      case TimeoutFailure:
        return 'РџСЂРµРІС‹С€РµРЅРѕ РІСЂРµРјСЏ РѕР¶РёРґР°РЅРёСЏ. РџРѕРїСЂРѕР±СѓР№С‚Рµ СЃРЅРѕРІР°.';
      case ValidationFailure:
        return 'РќРµРІРµСЂРЅС‹Рµ РґР°РЅРЅС‹Рµ. РџСЂРѕРІРµСЂСЊС‚Рµ email Рё РїР°СЂРѕР»СЊ.';
      case UnauthorizedFailure:
        return 'РќРµРІРµСЂРЅС‹Р№ email РёР»Рё РїР°СЂРѕР»СЊ.';
      case NotFoundFailure:
        return 'РџРѕР»СЊР·РѕРІР°С‚РµР»СЊ РЅРµ РЅР°Р№РґРµРЅ.';
      case NotImplementedFailure:
        return 'Р¤СѓРЅРєС†РёСЏ РЅРµ СЂРµР°Р»РёР·РѕРІР°РЅР°.';
      case StorageFailure:
        return 'РћС€РёР±РєР° СЃРѕС…СЂР°РЅРµРЅРёСЏ РґР°РЅРЅС‹С….';
      case PasswordUncorrectedFailure:
        return 'РќРµРІРµСЂРЅС‹Р№ РїР°СЂРѕР»СЊ.';
      case UserNotVerifyFailure:
        return 'РџРѕР»СЊР·РѕРІР°С‚РµР»СЊ РЅРµ РІРµСЂРёС„РёС†РёСЂРѕРІР°РЅ.';
      case UserNotFoundFailure:
        return 'РџРѕР»СЊР·РѕРІР°С‚РµР»СЊ РЅРµ РЅР°Р№РґРµРЅ.';
      case EmailAlreadyExistsFailure:
        return 'Email СѓР¶Рµ СЃСѓС‰РµСЃС‚РІСѓРµС‚.';
      default:
        return 'РџСЂРѕРёР·РѕС€Р»Р° РѕС€РёР±РєР°. РџРѕРїСЂРѕР±СѓР№С‚Рµ СЃРЅРѕРІР°.';
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    _authSubscription?.cancel();
    return super.close();
  }
}
