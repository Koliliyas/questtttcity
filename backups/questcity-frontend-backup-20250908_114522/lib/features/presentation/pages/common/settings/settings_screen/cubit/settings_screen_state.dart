part of 'settings_screen_cubit.dart';

abstract class SettingsScreenState extends Equatable {
  const SettingsScreenState();

  @override
  List<Object> get props => [];
}

class SettingsScreenInitial extends SettingsScreenState {
  final int roles;

  const SettingsScreenInitial({required this.roles});
}

class SettingsScreenLoading extends SettingsScreenState {}
