import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/features/data/models/person_model.dart';
import 'package:los_angeles_quest/features/data/models/user_model.dart';
import 'package:los_angeles_quest/features/domain/usecases/person/get_me.dart';
import 'package:los_angeles_quest/features/domain/usecases/person/update_me.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/ban_user.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/create_user.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/edit_user.dart';

import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'account_screen_state.dart';

class AccountScreenCubit extends Cubit<AccountScreenState> {
  final GetMe getMe;
  final BanUser banUser;
  final EditUser editUser;
  final CreateUser createUser;
  final UpdateMe updateMe;
  final SharedPreferences sharedPreferences;
  Role? role;
  final FlutterSecureStorage secureStorage;

  AccountScreenCubit({
    required this.getMe,
    required this.banUser,
    required this.editUser,
    required this.createUser,
    required this.updateMe,
    required this.sharedPreferences,
    required this.secureStorage,
    this.role,
  }) : super(AccountScreenLoading());

  Future<void> init({UserModel? user, required bool isCreateUser}) async {
    emit(AccountScreenLoading());
    late final UserModel? userModel;
    if (!isCreateUser) {
      if (user == null) {
        final person = await _getUserData();
        userModel = UserModel.fromPerson(person!);
      } else {
        userModel = user;
      }
    } else {
      userModel = null;
    }
    emit(AccountScreenLoaded(userModel));
  }

  Future<PersonModel?> _getUserData() async {
    final failureOrLoads = await getMe(NoParams());

    return failureOrLoads.fold(
      (error) {
        return null;
      },
      (person) => person,
    );
  }

  Future updateMeData() async {}

  Future logout() async {
    await secureStorage.delete(key: SharedPreferencesKeys.accessToken);
    await sharedPreferences.remove(SharedPreferencesKeys.role);
  }

  Future blockUser(String userId) async {
    await banUser(userId);
  }

  Future editUserData({
    required String firstName,
    required String lastName,
    required String email,
    required String id,
    required String username,
    required UserModel user,
    required String? instagram,
    required XFile? image,
  }) async {
    final changedFirstName = firstName != user.firstName ? firstName : null;
    final changedLastName = lastName != user.lastName ? lastName : null;
    final changedEmail = email != user.email ? email : null;
    final changedUsername = username != user.username ? username : null;
    final imageBytes = image != null ? await image.readAsBytes() : null;
    final encodedImage = imageBytes != null ? base64Encode(imageBytes) : null;
    await updateMe(
      EditUserParams(
        email: changedEmail,
        firstName: changedFirstName,
        lastName: changedLastName,
        id: id,
        username: changedUsername,
        instagram: instagram,
        image: encodedImage,
        profileId: user.profileId,
      ),
    );
  }

  Future<void> createAccount(
      {required String username,
      required String firstName,
      required String lastName,
      required String email,
      required String? instagram,
      required XFile? image,
      required int role,
      required String password}) async {
    final imageBytes = image != null ? await image.readAsBytes() : null;
    final encodedImage = imageBytes != null ? base64Encode(imageBytes) : null;
    await createUser(CreateUserParams(
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        instagram: instagram,
        image: encodedImage,
        role: role,
        password: password));
  }
}
