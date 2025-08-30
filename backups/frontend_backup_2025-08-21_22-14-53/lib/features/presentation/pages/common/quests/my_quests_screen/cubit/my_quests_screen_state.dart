part of 'my_quests_screen_cubit.dart';

abstract class MyQuestsScreenState extends Equatable {
  const MyQuestsScreenState();

  @override
  List<Object> get props => [];
}

class MyQuestsScreenInitial extends MyQuestsScreenState {}

class MyQuestsScreenUpdating extends MyQuestsScreenState {}

class MyQuestsScreenLoading extends MyQuestsScreenState {}

class MyQuestsScreenLoaded extends MyQuestsScreenState {
  final QuestListModel questsList;

  const MyQuestsScreenLoaded({required this.questsList});

  @override
  List<Object> get props => [questsList];
}

class MyQuestsScreenError extends MyQuestsScreenState {}
