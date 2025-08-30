import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/features/domain/repositories/user_repository.dart';


part 'password_screen_state.dart';

class PasswordScreenCubit extends Cubit<PasswordScreenState> {
  final UserRepository repository;

  PasswordScreenCubit(
    this.repository,
  ) : super(PasswordScreenInitial());

  Future<void> updatePassword(
      String oldPassword, String newPassword, String confirmPassword) async {
    try {
      await repository.changePassword(oldPassword, newPassword, confirmPassword);
    } catch (e) {
      emit(PasswordScreenError(message: e.toString()));
    }
  }
}
