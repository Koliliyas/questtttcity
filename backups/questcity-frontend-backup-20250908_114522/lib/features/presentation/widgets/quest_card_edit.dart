import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/custom_cache_manager.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_controller.dart';

class QuestCardEdit extends StatefulWidget {
  const QuestCardEdit({super.key, this.image, this.onChangeImage});

  final dynamic image;
  final Function(XFile image)? onChangeImage;

  @override
  State<QuestCardEdit> createState() => _QuestCardEditState();
}

class _QuestCardEditState extends State<QuestCardEdit> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GradientCard(
          height: 203.h,
          contentPadding: EdgeInsets.zero,
          body: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: widget.image != null
                  ? (widget.image is XFile)
                      ? Image.file(File(widget.image?.path ?? ''),
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width,
                          height: 189.w)
                      : CachedNetworkImage(
                          imageUrl: widget.image.toString(),
                          fit: BoxFit.fill,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: 189.w,
                          cacheManager: CustomCacheManager(),
                          errorWidget: (context, url, error) => Icon(
                              Icons.image,
                              size: 56.w,
                              color: UiConstants.greyColor),
                        )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 189.w,
                    )),
        ),
        Positioned(
          top: 14.w,
          right: 14.w,
          child: GestureDetector(
            onTap: () async {
              XFile? image = await EditQuestScreenController.pickImage();
              if (image != null && widget.onChangeImage != null) {
                widget.onChangeImage!(image);
              }
            },
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                  color: UiConstants.whiteColor, shape: BoxShape.circle),
              padding: getMarginOrPadding(all: 10),
              child: SvgPicture.asset(Paths.pencilIconPath),
            ),
          ),
        ),
      ],
    );
  }
}
