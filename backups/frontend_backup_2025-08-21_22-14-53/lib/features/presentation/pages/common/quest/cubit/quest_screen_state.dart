part of 'quest_screen_cubit.dart';

abstract class QuestScreenState extends Equatable {
  const QuestScreenState();

  @override
  List<Object> get props => [];
}

class QuestScreenInitial extends QuestScreenState {}

class QuestScreenLoading extends QuestScreenState {}

class QuestScreenError extends QuestScreenState {
  final String message;

  const QuestScreenError(this.message);

  @override
  List<Object> get props => [message];
}

class QuestScreenLoaded extends QuestScreenState {
  final QuestModel quest;
  final String vehicle;

  const QuestScreenLoaded({
    required this.quest,
    required this.vehicle,
  });

  @override
  List<Object> get props => [quest];
}
