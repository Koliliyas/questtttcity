import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/artifacts_screen/components/files/files_view.dart';
import 'package:open_file/open_file.dart';

class FileItem extends StatefulWidget {
  const FileItem({super.key, required this.file});

  final String file;

  @override
  State<FileItem> createState() => _FileItemState();
}

class _FileItemState extends State<FileItem> {
  late final FileType fileType;

  @override
  void initState() {
    if (extensionName == 'jpg' || extensionName == 'png') {
      fileType = FileType.image;
    } else if (extensionName == 'mp4') {
      fileType = FileType.video;
    } else {
      fileType = FileType.doc;
    }
    super.initState();
  }

  final androidTypes = {
    "doc": "application/msword",
    "pdf": "application/pdf",
    "jpg": "image/jpeg",
    "mp4": "video/mp4",
    "png": "image/png",
  };

  final iosTypes = {
    "doc": "application/msword",
    "jpg": "public.jpeg",
    "mp4": "public.mpeg-4",
    "pdf": "com.adobe.pdf",
    "png": "public.png",
  };

  late final extensionName =
      widget.file.split('.').isNotEmpty ? widget.file.split('.').last : 'file';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final filePath = widget.file;
        final extension = Platform.isIOS
            ? iosTypes[extensionName]
            : androidTypes[extensionName];
        await OpenFile.open(filePath, type: extension);
      },
      child: Container(
        decoration: BoxDecoration(
          color: UiConstants.blackColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (fileType != FileType.doc)
                Image.asset(Paths.category2Path,
                    fit: BoxFit.cover, height: double.infinity)
              else
                Text(
                  '.$extensionName',
                  style: UiConstants.textButton
                      .copyWith(color: UiConstants.whiteColor),
                ),
              Positioned(
                top: 9.w,
                right: 9.w,
                child: SvgPicture.asset(_getFloatingImage(),
                    width: 24.w, height: 24.w),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _getFloatingImage() {
    switch (fileType) {
      case FileType.doc:
        return Paths.document;
      case FileType.image:
        return Paths.camera;
      case FileType.video:
        return Paths.play;
    }
  }
}
