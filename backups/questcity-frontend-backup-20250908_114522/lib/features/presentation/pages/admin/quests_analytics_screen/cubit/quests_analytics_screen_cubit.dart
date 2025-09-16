import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_quest_analytics.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';

// Состояния экрана аналитики
abstract class QuestsAnalyticsScreenState extends Equatable {
  const QuestsAnalyticsScreenState();

  @override
  List<Object?> get props => [];
}

class QuestsAnalyticsScreenLoading extends QuestsAnalyticsScreenState {
  const QuestsAnalyticsScreenLoading();
}

class QuestsAnalyticsScreenLoaded extends QuestsAnalyticsScreenState {
  final Map<String, dynamic> analytics;

  const QuestsAnalyticsScreenLoaded({required this.analytics});

  @override
  List<Object?> get props => [analytics];
}

class QuestsAnalyticsScreenError extends QuestsAnalyticsScreenState {
  final String message;

  const QuestsAnalyticsScreenError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Cubit для управления состоянием экрана аналитики
class QuestsAnalyticsScreenCubit extends Cubit<QuestsAnalyticsScreenState> {
  final GetQuestAnalytics getQuestAnalyticsUC;

  QuestsAnalyticsScreenCubit({
    required this.getQuestAnalyticsUC,
  }) : super(const QuestsAnalyticsScreenLoading());

  // Загрузка аналитики
  Future<void> loadAnalytics() async {
    try {
      emit(const QuestsAnalyticsScreenLoading());

      final result = await getQuestAnalyticsUC(NoParams());

      result.fold(
        (failure) {
          emit(QuestsAnalyticsScreenError(message: failure.toString()));
        },
        (analytics) {
          emit(QuestsAnalyticsScreenLoaded(analytics: analytics));
        },
      );
    } catch (e) {
      emit(QuestsAnalyticsScreenError(message: e.toString()));
    }
  }

  // Обновление аналитики
  Future<void> refreshAnalytics() async {
    await loadAnalytics();
  }
}
