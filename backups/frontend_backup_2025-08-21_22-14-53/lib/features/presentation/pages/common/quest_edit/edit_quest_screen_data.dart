import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuestPreference {
  const QuestPreference(this.items, {this.title});
  final List<QuestPreferenceItem> items;
  final String? title;
}

class QuestPreferenceItem {
  QuestPreferenceItem(this.title,
      {this.image, this.subitems, this.textFieldEntry});
  final String title;
  final String? image;
  final QuestPreferenceSubItem? subitems;
  final QuestPreferenceItemTextField? textFieldEntry;
}

class QuestPreferenceItemTextField {
  QuestPreferenceItemTextField(this.hint, this.controller,
      {this.keyboardType = TextInputType.text,
      this.validator,
      this.inputFormatters,
      this.prefixText,
      this.isVisibleTextFieldWhenCheckedParent = false});
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final bool isVisibleTextFieldWhenCheckedParent;
}

class QuestPreferenceSubItem {
  const QuestPreferenceSubItem(this.subitems,
      {this.isHorizontalDirection = true,
      this.isVisibleWhenCheckedParent = false});
  final List<String> subitems;
  final bool isHorizontalDirection;
  final bool isVisibleWhenCheckedParent;
}

class PlaceData {
  final double longitude;
  final double latitude;
  final double detectionsRadius;
  final double height;
  final double interactionInaccuracy;
  final int? part;
  final bool? randomOccurrence;
  final double? randomOccurrenceRadius;

  const PlaceData({
    required this.longitude,
    required this.latitude,
    required this.detectionsRadius,
    required this.height,
    required this.interactionInaccuracy,
    this.part,
    this.randomOccurrence,
    this.randomOccurrenceRadius,
  });

  Map<String, dynamic> toJson() => {
        'longitude': longitude,
        'latitude': latitude,
        'detections_radius': detectionsRadius,
        'height': height,
        'interaction_inaccuracy': interactionInaccuracy,
        'part': part,
        'random_occurrence': randomOccurrence,
        'random_occurrence_radius': randomOccurrenceRadius,
      };

  factory PlaceData.fromJson(Map<String, dynamic> json) => PlaceData(
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        detectionsRadius: (json['detections_radius'] ?? 5.0).toDouble(),
        height: (json['height'] ?? 1.8).toDouble(),
        interactionInaccuracy:
            (json['interaction_inaccuracy'] ?? 5.0).toDouble(),
        part: json['part'],
        randomOccurrence: json['random_occurrence'],
        randomOccurrenceRadius: json['random_occurrence_radius']?.toDouble(),
      );
}

class PointEditData {
  final int pointIndex;
  final int? typeId;
  final int? toolId;
  final List<PlaceData>? places;
  final String? file;
  final String? typePhoto;
  final int? typeCode;
  final String? typeWord;
  final bool? isDivide;

  const PointEditData({
    required this.pointIndex,
    this.typeId,
    this.toolId,
    this.places,
    this.file,
    this.typePhoto,
    this.typeCode,
    this.typeWord,
    this.isDivide,
  });

  Map<String, dynamic> toJson() => {
        'pointIndex': pointIndex,
        'typeId': typeId,
        'toolId': toolId,
        'places': places?.map((place) => place.toJson()).toList(),
        'file': file,
        'typePhoto': typePhoto,
        'typeCode': typeCode,
        'typeWord': typeWord,
        'isDivide': isDivide,
      };

  factory PointEditData.fromJson(Map<String, dynamic> json) => PointEditData(
        pointIndex: json['pointIndex'] ?? 0,
        typeId: json['typeId'],
        toolId: json['toolId'],
        places: (json['places'] as List?)
            ?.map((place) => PlaceData.fromJson(place))
            .toList(),
        file: json['file'],
        typePhoto: json['typePhoto'],
        typeCode: json['typeCode'],
        typeWord: json['typeWord'],
        isDivide: json['isDivide'],
      );
}

class QuestEditLocationItem {
  const QuestEditLocationItem(
    this.title, {
    this.type,
    this.typeId,
    this.toolId,
    this.places,
    this.file,
    this.typePhoto,
    this.typeCode,
    this.typeWord,
    this.isDivide,
  });

  final String title;
  final String? type; // Тип точки (например, 'checkpoint', 'start', 'finish')
  final int? typeId; // ID типа активности
  final int? toolId; // ID инструмента
  final List<PlaceData>? places; // Список мест
  final String? file; // Файл
  final String? typePhoto; // Тип фото
  final int? typeCode; // Код типа
  final String? typeWord; // Слово типа
  final bool? isDivide; // Разделение артефакта
}
