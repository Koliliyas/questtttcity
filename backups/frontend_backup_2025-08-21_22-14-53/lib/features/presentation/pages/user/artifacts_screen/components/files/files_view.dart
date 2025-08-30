import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/files/file_item.dart';

class FilesView extends StatelessWidget {
  final List<String> files;
  const FilesView({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      height: 385.h,
      contentPadding: getMarginOrPadding(all: 16),
      borderRadius: 24.r,
      hasBlur: true,
      body: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.w,
        ),
        itemCount: files.length,
        itemBuilder: (context, index) => FileItem(file: files[index]),
      ),
    );
  }
}

enum FileType { image, video, doc }
