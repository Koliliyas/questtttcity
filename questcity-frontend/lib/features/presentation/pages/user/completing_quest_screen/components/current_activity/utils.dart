import 'package:equatable/equatable.dart';

enum ActivityTypes { qrCode, combinationLocker, photo, file, word }

sealed class ActivityType extends Equatable {
  final String name;
  final String description;
  final String initialAction;
  final String finalAction;
  final String initialImage;
  final int pointNumber;
  final int questId;

  const ActivityType(
      {required this.name,
      required this.description,
      required this.initialAction,
      required this.finalAction,
      required this.initialImage,
      required this.pointNumber,
      required this.questId});

  const factory ActivityType.qrCode(
      {required String name,
      required String description,
      required String initialAction,
      required String finalAction,
      required String initialImage,
      required int pointNumber,
      required int questId}) = QrCodeActivity;

  const factory ActivityType.combinationLocker(
      {required String name,
      required String description,
      required String initialAction,
      required String finalAction,
      required String correctAnswer,
      required int pointNumber,
      required int questId,
      required String initialImage}) = CombinationLockerActivity;

  const factory ActivityType.photo(
      {required String name,
      required String description,
      required String initialAction,
      required int pointNumber,
      required int questId,
      required String finalAction,
      required String initialImage}) = PhotoActivity;

  const factory ActivityType.file(
      {required String name,
      required String description,
      required String initialAction,
      required int pointNumber,
      required int questId,
      required String finalAction,
      required Map<String, String> files,
      required String initialImage}) = FileActivity;

  const factory ActivityType.word(
      {required String name,
      required String description,
      required String initialAction,
      required int pointNumber,
      required int questId,
      required String finalAction,
      required String correctAnswer,
      required String initialImage}) = WordActivity;

  @override
  List<Object> get props => [name, description, initialAction, finalAction, initialImage];
}

class QrCodeActivity extends ActivityType {
  const QrCodeActivity(
      {required super.name,
      required super.description,
      required super.initialAction,
      required super.finalAction,
      required super.initialImage,
      required super.pointNumber,
      required super.questId});
}

class CombinationLockerActivity extends ActivityType {
  final String correctAnswer;
  const CombinationLockerActivity(
      {required this.correctAnswer,
      required super.name,
      required super.description,
      required super.initialAction,
      required super.finalAction,
      required super.initialImage,
      required super.pointNumber,
      required super.questId});

  @override
  List<Object> get props => [correctAnswer, ...super.props];
}

class PhotoActivity extends ActivityType {
  const PhotoActivity(
      {required super.name,
      required super.description,
      required super.initialAction,
      required super.finalAction,
      required super.initialImage,
      required super.pointNumber,
      required super.questId});
}

class FileActivity extends ActivityType {
  final Map<String, String> files;

  const FileActivity(
      {required this.files,
      required super.name,
      required super.description,
      required super.initialAction,
      required super.finalAction,
      required super.initialImage,
      required super.pointNumber,
      required super.questId});

  @override
  List<Object> get props => [files, ...super.props];
}

class WordActivity extends ActivityType {
  final String correctAnswer;
  const WordActivity(
      {required this.correctAnswer,
      required super.name,
      required super.description,
      required super.initialAction,
      required super.finalAction,
      required super.initialImage,
      required super.pointNumber,
      required super.questId});

  @override
  List<Object> get props => [correctAnswer, ...super.props];
}
