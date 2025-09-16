part of 'artifacts_screen_cubit.dart';

abstract class ArtifactsScreenState extends Equatable {
  const ArtifactsScreenState();

  @override
  List<Object> get props => [];
}

class ArtifactsScreenInitial extends ArtifactsScreenState {}

class ArtifactsScreenFiles extends ArtifactsScreenState {
  final List<String> files;

  const ArtifactsScreenFiles({required this.files});
}

class ArtifactsScreenTools extends ArtifactsScreenState {}

class ArtifactsScreenTool extends ArtifactsScreenState {
  final String image;
  final String title;
  final int collectedParts;

  const ArtifactsScreenTool(
      {required this.image, required this.title, required this.collectedParts});

  @override
  List<Object> get props => [image, title, collectedParts];
}

class ArtifactsScreenArtifacts extends ArtifactsScreenState {}

class ArtifactsScreenArtifact extends ArtifactsScreenState {
  final String image;
  final bool isCollected;

  const ArtifactsScreenArtifact(
      {required this.image, required this.isCollected});

  @override
  List<Object> get props => [image, isCollected];
}
