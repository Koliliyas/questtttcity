import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

class EditQuestPointFilesChipByPhotoBody extends StatelessWidget {
  const EditQuestPointFilesChipByPhotoBody({
    super.key,
    required this.photo,
  });
  final XFile? photo;

  @override
  Widget build(BuildContext context) {
    return photo != null
        ? GradientCard(
            contentMargin: EdgeInsets.zero,
            borderRadius: 20.r,
            body: Image.file(
              File(photo?.path ?? ''),
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              height: 383.h,
            ))
        : Container();
  }
}
