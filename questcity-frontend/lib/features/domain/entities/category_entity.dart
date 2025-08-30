import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String title;
  final String photoPath;

  const CategoryEntity({
    required this.id,
    required this.title,
    required this.photoPath,
  });

  @override
  List<Object?> get props => [id, title, photoPath];
}
