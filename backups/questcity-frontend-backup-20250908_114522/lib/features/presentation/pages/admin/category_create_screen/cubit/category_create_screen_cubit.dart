import 'dart:convert';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:los_angeles_quest/features/data/models/category_model.dart';
import 'package:los_angeles_quest/features/domain/entities/category_entity.dart';
import 'package:los_angeles_quest/features/domain/usecases/category/create_category.dart';
import 'package:los_angeles_quest/features/domain/usecases/category/update_category.dart';
import 'package:los_angeles_quest/features/domain/usecases/file/upload_file.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/cubit/quests_screen_cubit.dart';

part 'category_create_screen_state.dart';

class CategoryCreateScreenCubit extends Cubit<CategoryCreateScreenState> {
  final CategoryEntity? category;
  final UpdateCategory updateCategoryUC;
  final CreateCategory createCategoryUC;
  final UploadFile uploadFileUC;

  CategoryCreateScreenCubit({
    this.category,
    required this.createCategoryUC,
    required this.updateCategoryUC,
    required this.uploadFileUC,
  }) : super(const CategoryCreateScreenInitial()) {
    nameCategoryController.text = category?.title ?? '';
  }

  TextEditingController nameCategoryController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  onTapQuest(int index) {
    CategoryCreateScreenInitial currentState = state as CategoryCreateScreenInitial;

    List<int> selectedQuestIndexes = [...currentState.selectedQuestIndexes];

    if (selectedQuestIndexes.contains(index)) {
      selectedQuestIndexes.remove(index);
    } else {
      selectedQuestIndexes.add(index);
    }
    emit(currentState.copyWith(selectedQuestIndexes: selectedQuestIndexes));
  }

  changeImage(XFile image) {
    CategoryCreateScreenInitial currentState = state as CategoryCreateScreenInitial;
    emit(currentState.copyWith(image: image));
  }

  Future updateCategory(BuildContext context) async {
    bool isValidData = _validateData(context);
    if (formKey.currentState!.validate()) {
      if (isValidData) {
        CategoryCreateScreenInitial currentState = state as CategoryCreateScreenInitial;
        String? path;
        if (currentState.image != null) {
          path = await _uploadPhoto(context);
          if (path == null) return;
        }

        final failureOrLoads = await updateCategoryUC(CategoryModel(
            id: category!.id,
            name: nameCategoryController.text,
            image: path ?? category!.photoPath));

        failureOrLoads.fold(
          (error) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Unexpected Error'),
          )),
          (_) {
            context.read<QuestsScreenCubit>().loadData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Category successfully updated'),
              ),
            );
          },
        );
      }
    }
  }

  Future createCategory(BuildContext context) async {
    bool isValidData = _validateData(context);
    if (formKey.currentState!.validate()) {
      if (isValidData) {
        CategoryCreateScreenInitial currentState = state as CategoryCreateScreenInitial;

        final base64Image = await File(currentState.image!.path).readAsBytes();
        final base64String = base64Encode(base64Image);
        final failureOrLoads = await createCategoryUC(
            CategoryModel(id: -1, name: nameCategoryController.text, image: base64String));

        failureOrLoads.fold(
          (error) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Unexpected Error'),
          )),
          (_) async {
            context.read<QuestsScreenCubit>().loadData();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Category successfully created'),
            ));
            Navigator.pop(context);
          },
        );
      }
    }
  }

  Future<String?> _uploadPhoto(BuildContext context) async {
    CategoryCreateScreenInitial currentState = state as CategoryCreateScreenInitial;

    final failureOrLoads = await uploadFileUC(File(currentState.image!.path));

    return failureOrLoads.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload Image Error'),
          ),
        );
        return null;
      },
      (path) => path,
    );
  }

  bool _validateData(BuildContext context) {
    if (formKey.currentState!.validate()) {
      CategoryCreateScreenInitial currentState = state as CategoryCreateScreenInitial;

      if (currentState.image == null && category?.photoPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to upload an image'),
          ),
        );
      } else {
        return true;
      }
    }

    return false;
  }
}
