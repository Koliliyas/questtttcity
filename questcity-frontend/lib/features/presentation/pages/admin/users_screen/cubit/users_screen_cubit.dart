import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/features/domain/entities/user_entity.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/ban_user.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/get_all_users.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/unlock_requests.dart';

part 'users_screen_state.dart';

class UsersScreenCubit extends Cubit<UsersScreenState> {
  GetAllUsers getAllUsersUC;
  UnlockRequests getUnlockRequests;
  BanUser banUserUC;
  UsersScreenCubit(
      {required this.getAllUsersUC,
      required this.banUserUC,
      required this.getUnlockRequests})
      : super(UsersScreenLoading()) {
    searchController.addListener(_onSearchTextChanged);
  }

  TextEditingController searchController = TextEditingController();

  List<UserEntity> users = [];
  List<UserEntity> unlockRequests = [];

  Future getAllUsers({String? search}) async {
    emit(UsersScreenLoading());
    final failureOrLoads =
        await getAllUsersUC(GetAllUsersParams(search: search));

    List<UnlockRequest> unlockRequests = [];
    try {
      unlockRequests = await getUnlockRequests.getUnlockRequests();
    } catch (e) {
      // Игнорируем ошибку и используем пустой список
      unlockRequests = [];
    }

    failureOrLoads.fold(
        (error) => emit(const UsersScreenError(message: 'Server Failure')),
        (usersList) async {
      users = usersList
          .where(
            (user) => (user.role != -1) && (user.isActive),
          )
          .toList();

      users = sortUsers(users);
    });
    emit(UsersScreenLoaded(
        usersList: users,
        searchText: '',
        activePageView: 0,
        unlockRequests: unlockRequests));
  }

  changeChip(int index) {
    emit((state as UsersScreenLoaded).copyWith(activePageView: index));
  }

  void _onSearchTextChanged() {
    if (state is UsersScreenLoaded) {
      UsersScreenLoaded currentState = state as UsersScreenLoaded;
      users = currentState.usersList!
          .where((e) => ("${e.firstName} ${e.lastName}".toLowerCase())
              .startsWith(searchController.text.toLowerCase()))
          .toList();
      emit(currentState.copyWith(searchText: searchController.text));
    }
  }

  Future<bool> unlockUser(String id, String reason) async {
    try {
      return await getUnlockRequests.updateRequest(id, reason);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }

  List<UserEntity> sortUsers(List<UserEntity> usersList) {
    // Фильтруем и сортируем пользователей с ролью "Менеджер"
    List<UserEntity> managers = usersList
        .where((user) => user.role == 1)
        .toList()
      ..sort((a, b) =>
          DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)));

    // Фильтруем и сортируем остальных пользователей (кроме "Администраторов" и "Менеджеров")
    List<UserEntity> others = usersList.where((user) => user.role != 1).toList()
      ..sort((a, b) =>
          DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)));

    // Объединяем оба списка: сначала "Менеджеры", затем остальные
    return [...managers, ...others];
  }
}
