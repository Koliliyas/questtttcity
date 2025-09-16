part of 'users_screen_cubit.dart';

abstract class UsersScreenState extends Equatable {
  const UsersScreenState();

  @override
  List<Object?> get props => [];
}

class UsersScreenLoaded extends UsersScreenState {
  final List<UserEntity>? usersList;
  final List<UnlockRequest> unlockRequests;
  final String? searchText;
  final int? activePageView;

  const UsersScreenLoaded(
      {this.usersList, this.searchText, this.activePageView, this.unlockRequests = const []});

  UsersScreenLoaded copyWith(
      {List<UserEntity>? usersList,
      String? searchText,
      int? activePageView,
      List<UnlockRequest>? unlockRequests}) {
    return UsersScreenLoaded(
      usersList: usersList ?? this.usersList ?? [],
      searchText: searchText ?? this.searchText ?? '',
      activePageView: activePageView ?? this.activePageView ?? 0,
      unlockRequests: unlockRequests ?? this.unlockRequests,
    );
  }

  @override
  List<Object?> get props => [
        usersList,
        searchText,
        activePageView,
      ];
}

class UsersScreenLoading extends UsersScreenState {}

class UsersScreenError extends UsersScreenState {
  final String message;

  const UsersScreenError({required this.message});

  @override
  List<Object> get props => [message];
}
