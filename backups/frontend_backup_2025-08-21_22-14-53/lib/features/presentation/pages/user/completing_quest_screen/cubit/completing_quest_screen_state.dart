part of 'completing_quest_screen_cubit.dart';

abstract class CompletingQuestScreenState extends Equatable {
  const CompletingQuestScreenState();

  @override
  List<Object> get props => [];
}

class CompletingQuestScreenInitial extends CompletingQuestScreenState {}

class CompletingQuestScreenHint extends CompletingQuestScreenState {}

class CompletingQuestScreenLoaded extends CompletingQuestScreenState {
  final CurrentQuestModel quest;
  final int currentPoint;
  final bool completed;

  const CompletingQuestScreenLoaded({
    required this.completed,
    required this.quest,
    required this.currentPoint,
  });

  @override
  // TODO: implement props
  List<Object> get props => [quest, currentPoint];
}

class CompletingQuestScreenActivity extends CompletingQuestScreenState {
  const CompletingQuestScreenActivity(
      {required this.activityType, required this.isCompleted, required this.isHintShow});

  final ActivityType activityType;
  final bool isCompleted;
  final bool isHintShow;

  @override
  List<Object> get props => [activityType, isCompleted, isHintShow];

  CompletingQuestScreenActivity copyWith(
      {ActivityType? activityType, bool? isCompleted, bool? isHintShow}) {
    return CompletingQuestScreenActivity(
      activityType: activityType ?? this.activityType,
      isCompleted: isCompleted ?? this.isCompleted,
      isHintShow: isHintShow ?? this.isHintShow,
    );
  }
}
