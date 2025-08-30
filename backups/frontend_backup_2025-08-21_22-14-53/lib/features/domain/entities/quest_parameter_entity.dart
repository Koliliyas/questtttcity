import 'package:equatable/equatable.dart';

class QuestParameterEntity extends Equatable {
  final int id;
  final String title;

  const QuestParameterEntity({required this.id, required this.title});

  @override
  List<Object?> get props => [id, title];
}
