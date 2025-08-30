part of 'splash_screen_cubit.dart';

abstract class SplashScreenState extends Equatable {
  const SplashScreenState();

  @override
  List<Object> get props => [];
}

class SplashScreenLoading extends SplashScreenState {}

class SplashScreenLoaded extends SplashScreenState {
  final bool isHasAppAuth;
  final Role? role;
  final String? username;

  const SplashScreenLoaded({this.username, required this.isHasAppAuth, this.role});
}
