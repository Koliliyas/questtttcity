import 'package:los_angeles_quest/features/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  @override
  final int id;
  final String name;
  final String image;

  const CategoryModel({required this.id, required this.name, required this.image})
      : super(id: id, title: name, photoPath: image);

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json["id"],
        name: json["name"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
      };
}
