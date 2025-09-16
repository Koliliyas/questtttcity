import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/features/data/models/quests/current_quest_model.dart';
import 'package:los_angeles_quest/features/domain/repositories/quest_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../constants/paths.dart';
import '../components/current_activity/current_activity.dart';

part 'completing_quest_screen_state.dart';

class CompletingQuestScreenCubit extends Cubit<CompletingQuestScreenState> {
  final QuestRepository repository;
  CompletingQuestScreenCubit(this.repository)
      : super(CompletingQuestScreenInitial()) {
    _init();
  }

  _init() async {
    prefs = await SharedPreferences.getInstance();
  }

  late SharedPreferences prefs;
  hideOrShowHint() {
    final currentState = state as CompletingQuestScreenActivity;
    emit((currentState).copyWith(isHintShow: !currentState.isHintShow));
  }

  void getData(int id) async {
    emit(CompletingQuestScreenInitial());
    final data = await repository.getCurrentQuest(id);
    final currentPoint = prefs.getInt('quest_$id') ?? 0;
    emit(CompletingQuestScreenLoaded(
        quest: data,
        currentPoint: currentPoint,
        completed: currentPoint >= data.points.length));
  }

  void updatePoint({required int point, required int id}) {
    prefs.setInt('quest_$id', point);
  }

  void getCurrentPoint(int id) {
    final currentState = state as CompletingQuestScreenLoaded;
    final currentPoint = prefs.getInt('quest_$id') ?? 0;
    emit(CompletingQuestScreenLoaded(
        quest: currentState.quest,
        currentPoint: currentPoint,
        completed: currentPoint >= currentState.quest.points.length));
  }

  void getCurrentActivity(QuestPointModel activityType, int point, int id) {
    emit(CompletingQuestScreenActivity(
        activityType: _getActivityType(activityType, point, id),
        isCompleted: false,
        isHintShow: false));
  }

  void completeActivity({required int point, required int id}) {
    updatePoint(point: point + 1, id: id);
    emit((state as CompletingQuestScreenActivity).copyWith(isCompleted: true));
  }

  ActivityType _getActivityType(
      QuestPointModel activityType, int point, int id) {
    if (activityType.type.typeCode != null) {
      return CombinationLockerActivity(
        questId: id,
        pointNumber: point,
        correctAnswer: activityType.type.typeCode.toString(),
        name: activityType.name,
        description: activityType.description,
        initialAction: 'Enter the code',
        finalAction: 'Open',
        initialImage: Paths.wordLockerHidden,
      );
    }
    if (activityType.type.typeWord != null) {
      return WordActivity(
        questId: id,
        pointNumber: point,
        correctAnswer: activityType.type.typeWord!,
        name: activityType.name,
        description: activityType.description,
        initialAction: 'Enter the word',
        finalAction: 'Submit',
        initialImage: Paths.artifactWordLockerIcon,
      );
    }
    if (activityType.files != null && activityType.files!.file != null) {
      return FileActivity(
        questId: id,
        pointNumber: point,
        name: activityType.name,
        description: activityType.description,
        initialAction: 'Open the file',
        finalAction: 'Read',
        files: {
          activityType.files!.file!.split('/').isNotEmpty
              ? activityType.files!.file!.split('/').last
              : 'file': activityType.files!.file!
        },
        initialImage: Paths.files,
      );
    }
    if (activityType.type.typePhoto != null) {
      return PhotoActivity(
        questId: id,
        pointNumber: point,
        name: activityType.name,
        description: activityType.description,
        initialAction: 'Take a photo',
        finalAction: 'Share with friends',
        initialImage: Paths.artifactCameraIcon,
      );
    }
    return QrCodeActivity(
      questId: id,
      pointNumber: point,
      name: 'QR Code',
      description: 'Scan the QR code',
      initialAction: 'Scan the code',
      finalAction: 'Open',
      initialImage: Paths.artifactQrScannerIcon,
    );
  }

  Future<void> saveFile(String fileUrl, String fileName) async {
    final fileData = (await http.get(Uri.parse(fileUrl))).bodyBytes;
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    await File(path).writeAsBytes(fileData);
  }
}
