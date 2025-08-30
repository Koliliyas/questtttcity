import 'package:bloc/bloc.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:path_provider/path_provider.dart';

part 'artifacts_screen_state.dart';

class ArtifactsScreenCubit extends Cubit<ArtifactsScreenState> {
  ArtifactsScreenCubit() : super(ArtifactsScreenInitial());

  String appBarTitle = LocaleKeys.kTextArtifacts.tr();

  updateView(
    ArtifactsViewType artifactsViewType, {
    String? image,
    String? title,
    int? collectedParts,
    bool? isCollected,
    bool? isHidden,
  }) async {
    ArtifactsScreenState artifactsScreenState = ArtifactsScreenInitial();
    switch (artifactsViewType) {
      case ArtifactsViewType.start:
        appBarTitle = LocaleKeys.kTextArtifacts.tr();
        artifactsScreenState = ArtifactsScreenInitial();
      case ArtifactsViewType.tools:
        appBarTitle = 'Tools parts';
        artifactsScreenState = ArtifactsScreenTools();
      case ArtifactsViewType.tool:
        appBarTitle = title ?? 'Meter radar';
        artifactsScreenState = ArtifactsScreenTool(
            image: image!, title: title!, collectedParts: collectedParts!);
      case ArtifactsViewType.files:
        appBarTitle = LocaleKeys.kTextFiles.tr();
        final directory = await getApplicationDocumentsDirectory();
        final files = directory.listSync().where((element) {
          return element.path.contains('.pdf') ||
              element.path.contains('.doc') ||
              element.path.contains('.mp4') ||
              element.path.contains('.jpg') ||
              element.path.contains('.png');
        }).toList();
        artifactsScreenState = ArtifactsScreenFiles(
          files: files.map((e) => e.path).toList(),
        );
      case ArtifactsViewType.artifacts:
        appBarTitle = 'РЎollected artifacts';
        artifactsScreenState = ArtifactsScreenArtifacts();
      case ArtifactsViewType.artifact:
        appBarTitle = title ?? LocaleKeys.kTextCodeWord.tr();
        artifactsScreenState =
            ArtifactsScreenArtifact(image: image!, isCollected: isCollected!);
    }
    emit(artifactsScreenState);
  }

  onTapBack() {
    if (state is ArtifactsScreenArtifact) {
      appBarTitle = 'РЎollected artifacts';
      emit(ArtifactsScreenArtifacts());
    } else if (state is ArtifactsScreenTool) {
      appBarTitle = 'Tools parts';
      emit(ArtifactsScreenTools());
    } else if (state is! ArtifactsScreenInitial) {
      appBarTitle = LocaleKeys.kTextArtifacts.tr();
      emit(ArtifactsScreenInitial());
    }
  }
}

enum ArtifactsViewType { start, tools, tool, files, artifacts, artifact }

