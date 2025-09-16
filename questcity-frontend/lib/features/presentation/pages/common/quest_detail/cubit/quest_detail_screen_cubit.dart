import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_list_model.dart';
import 'package:los_angeles_quest/features/domain/usecases/quest/get_quest_detail.dart';

// States
abstract class QuestDetailScreenState extends Equatable {
  const QuestDetailScreenState();

  @override
  List<Object?> get props => [];
}

class QuestDetailScreenLoading extends QuestDetailScreenState {}

class QuestDetailScreenLoaded extends QuestDetailScreenState {
  final QuestItem questItem;
  final QuestDetails? questDetails;

  const QuestDetailScreenLoaded({
    required this.questItem,
    this.questDetails,
  });

  @override
  List<Object?> get props => [questItem, questDetails];
}

class QuestDetailScreenError extends QuestDetailScreenState {
  final String message;

  const QuestDetailScreenError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Quest Details Model (extended information)
class QuestDetails extends Equatable {
  final int id;
  final String name;
  final String description;
  final String image;
  final double rating;
  final MainPreferences mainPreferences;
  final List<QuestPoint> points;
  final List<QuestReview> reviews;
  final List<QuestMerchandise> merch;
  final QuestCredits credits;

  const QuestDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.rating,
    required this.mainPreferences,
    required this.points,
    required this.reviews,
    required this.merch,
    required this.credits,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        rating,
        mainPreferences,
        points,
        reviews,
        merch,
        credits,
      ];
}

class QuestPoint extends Equatable {
  final int id;
  final String name;
  final String description;
  final String image;
  final double latitude;
  final double longitude;
  final String type; // 'start', 'end', 'halfway'

  const QuestPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.type,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        latitude,
        longitude,
        type,
      ];
}

class QuestReview extends Equatable {
  final int id;
  final String userName;
  final String text;
  final int rating;
  final String createdAt;

  const QuestReview({
    required this.id,
    required this.userName,
    required this.text,
    required this.rating,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userName, text, rating, createdAt];
}

class QuestMerchandise extends Equatable {
  final int id;
  final String name;
  final String description;
  final String image;
  final int price;

  const QuestMerchandise({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, description, image, price];
}

class QuestCredits extends Equatable {
  final int cost;
  final int reward;
  final bool autoAccrual;

  const QuestCredits({
    required this.cost,
    required this.reward,
    required this.autoAccrual,
  });

  @override
  List<Object?> get props => [cost, reward, autoAccrual];
}

// Cubit
class QuestDetailScreenCubit extends Cubit<QuestDetailScreenState> {
  final GetQuestDetail _getQuestDetail;

  QuestDetailScreenCubit(this._getQuestDetail) : super(QuestDetailScreenLoading());

  void loadQuestDetails(int questId, QuestItem? questItem) async {
    try {
      emit(QuestDetailScreenLoading());

      // Load quest details from API
      final questDetails = await _getQuestDetail(questId);
      
      // Create QuestItem from API data if not provided
      final questItemFromApi = questItem ?? QuestItem(
        id: questDetails.id,
        name: questDetails.name,
        image: questDetails.image,
        rating: questDetails.rating,
        mainPreferences: questDetails.mainPreferences,
      );

      emit(QuestDetailScreenLoaded(
        questItem: questItemFromApi,
        questDetails: questDetails,
      ));
    } catch (e) {
      emit(QuestDetailScreenError(
        message: "Failed to load quest details: $e",
      ));
    }
  }

}
