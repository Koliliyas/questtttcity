import 'package:equatable/equatable.dart';

class CurrentQuestModel extends Equatable {
  final String mentorPreferences;
  final List<QuestPointModel> points;

  const CurrentQuestModel({
    required this.mentorPreferences,
    required this.points,
  });

  factory CurrentQuestModel.fromJson(Map<String, dynamic> json) {
    return CurrentQuestModel(
      mentorPreferences: json['mentorPreferences'] as String,
      points: (json['points'] as List<dynamic>)
          .map((point) => QuestPointModel.fromJson(point))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'mentorPreferences': mentorPreferences,
        'points': points.map((point) => point.toJson()).toList(),
      };

  @override
  List<Object?> get props => [mentorPreferences, points];
}

class QuestPointModel extends Equatable {
  final String name;
  final int order;
  final String description;
  final PointTypeModel type;
  final int? toolId;
  final PlaceModel place;
  final FileModel? files;

  const QuestPointModel({
    required this.name,
    required this.order,
    required this.description,
    required this.type,
    required this.toolId,
    required this.place,
    required this.files,
  });

  factory QuestPointModel.fromJson(Map<String, dynamic> json) {
    return QuestPointModel(
      name: json['nameOfLocation'] as String,
      order: json['order'] as int,
      description: json['description'] as String,
      type: PointTypeModel.fromJson(json['type']),
      toolId: json['tool_id'] as int?,
      place: json['places'] is List && (json['places'] as List).isNotEmpty
          ? PlaceModel.fromJson((json['places'] as List).first)
          : PlaceModel(
              part: 0,
              longitude: 0.0,
              latitude: 0.0,
              interactionInaccuracy: 0.0),
      files: FileModel.fromJson(json['files']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'order': order,
        'description': description,
        'type': type.toJson(),
        'toolId': toolId,
        'place': place.toJson(),
        'files': files?.toJson(),
      };

  @override
  List<Object?> get props => [
        name,
        order,
        description,
        type,
        toolId,
        place,
        files,
      ];
}

class PointTypeModel extends Equatable {
  final int? typeId;
  final String? typePhoto;
  final String? typeCode;
  final String? typeWord;

  const PointTypeModel({
    required this.typeId,
    this.typePhoto,
    this.typeCode,
    this.typeWord,
  });

  factory PointTypeModel.fromJson(Map<String, dynamic> json) {
    return PointTypeModel(
      typeId: json['typeId'] as int?,
      typePhoto: json['typePhoto'] as String?,
      typeCode: json['typeCode'] as String?,
      typeWord: json['typeWord'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'typeId': typeId,
        'typePhoto': typePhoto,
        'typeCode': typeCode,
        'typeWord': typeWord,
      };

  @override
  List<Object?> get props => [typeId, typePhoto, typeCode, typeWord];
}

class PlaceModel extends Equatable {
  final int? part;
  final double longitude;
  final double latitude;
  final double? detectionsRadius;
  final double? height;
  final double? randomOccurrence;
  final double? interactionInaccuracy;

  const PlaceModel({
    required this.part,
    required this.longitude,
    required this.latitude,
    this.detectionsRadius,
    this.height,
    this.randomOccurrence,
    required this.interactionInaccuracy,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      part: json['part'] as int?,
      longitude: json['longitude'] as double,
      latitude: json['latitude'] as double,
      detectionsRadius: json['detectionsRadius'] as double?,
      height: json['height'] as double?,
      randomOccurrence: json['randomOccurrence'] as double?,
      interactionInaccuracy: json['interactionInaccuracy'] as double?,
    );
  }

  Map<String, dynamic> toJson() => {
        'part': part,
        'longitude': longitude,
        'latitude': latitude,
        'detectionsRadius': detectionsRadius,
        'height': height,
        'randomOccurrence': randomOccurrence,
        'interactionInaccuracy': interactionInaccuracy,
      };

  @override
  List<Object?> get props => [
        part,
        longitude,
        latitude,
        detectionsRadius,
        height,
        randomOccurrence,
        interactionInaccuracy,
      ];
}

class FileModel extends Equatable {
  final String? file;
  final bool? isDivide;

  const FileModel({
    required this.file,
    this.isDivide,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      file: json['file'] as String?,
      isDivide: json['isDivide'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'file': file,
        'isDivide': isDivide,
      };

  @override
  List<Object?> get props => [file, isDivide];
}
