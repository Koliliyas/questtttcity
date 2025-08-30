import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/features/domain/usecases/person/get_me.dart';

part 'settings_screen_state.dart';

class SettingsScreenCubit extends Cubit<SettingsScreenState> {
  final GetMe getMe;
  SettingsScreenCubit({
    required this.getMe,
  }) : super(SettingsScreenLoading());

  Future getMeData() async {
    final failureOrLoads = await getMe(NoParams());
    int roles = -1;
    failureOrLoads.fold(
      (_) {},
      (person) {
        roles = person.role;
      },
    );
    emit(SettingsScreenInitial(roles: roles));
  }
}
