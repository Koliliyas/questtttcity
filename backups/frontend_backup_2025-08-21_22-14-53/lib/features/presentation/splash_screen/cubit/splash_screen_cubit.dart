import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/reload_token.dart';
import 'package:los_angeles_quest/features/domain/usecases/person/get_me.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'splash_screen_state.dart';

class SplashScreenCubit extends Cubit<SplashScreenState> {
  final GetMe getMe;
  final ReloadToken reloadToken;
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;
  SplashScreenCubit({
    required this.getMe,
    required this.reloadToken,
    required this.sharedPreferences,
    required this.secureStorage,
  }) : super(SplashScreenLoading());

  Future checkData() async {
    bool? isRememberUser =
        sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser);

    if (isRememberUser != true) {
      emit(const SplashScreenLoaded(isHasAppAuth: false));
      return; // Добавить return для избежания дальнейшего выполнения
    }

    final String? serverToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);
    if (serverToken == null) {
      emit(const SplashScreenLoaded(isHasAppAuth: false));
      return;
    }

    try {
      var data = await _getUserData();
      bool isTokenValid = data != null;

      if (!isTokenValid) {
        await reloadToken(NoParams());
        data = await _getUserData();
        isTokenValid = data != null;
      }

      int? role = sharedPreferences.getInt(SharedPreferencesKeys.role);

      if (isTokenValid && role != null) {
        emit(SplashScreenLoaded(
            username: data,
            isHasAppAuth: true,
            role: Utils.convertServerRoleToEnumItem(role)));
      } else {
        emit(const SplashScreenLoaded(isHasAppAuth: false));
      }
    } catch (e) {
      // Обработка ошибок при проверке токена
      emit(const SplashScreenLoaded(isHasAppAuth: false));
    }
  }

  Future<String?> _getUserData() async {
    final failureOrLoads = await getMe(NoParams());

    return failureOrLoads.fold(
      (_) => null,
      (person) async {
        await sharedPreferences.setInt(SharedPreferencesKeys.role, person.role);
        // await sharedPreferences.setString(
        //     SharedPreferencesKeys.socketToken, person.token!);
        return person.username;
      },
    );
  }
}
