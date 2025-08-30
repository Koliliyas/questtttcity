import 'package:los_angeles_quest/features/domain/entities/quest_parameter_entity.dart';

class QuestParameterModel extends QuestParameterEntity {
  @override
  final int id;
  @override
  final String title;

  const QuestParameterModel({required this.id, required this.title}) : super(id: id, title: title);

  factory QuestParameterModel.fromJson(Map<String, dynamic> json) => QuestParameterModel(
        id: json["id"],
        title: json["name"],
      );

  Map<String, dynamic> toJson() => {"id": id, "name": title};
}
