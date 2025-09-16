import 'dart:io';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class MerchPreferencesBody extends StatelessWidget {
  const MerchPreferencesBody(
      {super.key,
      required this.addedImage,
      required this.merchImages,
      required this.merchDescriptionController,
      required this.merchPriceController});

  final Function(XFile) addedImage;
  final List<XFile> merchImages;
  final TextEditingController merchDescriptionController;
  final TextEditingController merchPriceController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
            hintText: LocaleKeys.kTextMerchDescription.tr(),
            controller: merchDescriptionController,
            fillColor: UiConstants.whiteColor,
            textStyle:
                UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
            textColor: UiConstants.blackColor,
            isExpanded: true,
            validator: (value) => Utils.validate(value),
            textInputAction: TextInputAction.next),
        SizedBox(height: 12.h),
        CustomTextField(
            hintText: LocaleKeys.kTextMerchPrice.tr(),
            controller: merchPriceController,
            keyboardType: TextInputType.number,
            fillColor: UiConstants.whiteColor,
            textStyle:
                UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
            textColor: UiConstants.blackColor,
            isExpanded: true,
            validator: (value) => Utils.validate(value),
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp(r'\s'),
              ),
              FilteringTextInputFormatter.digitsOnly
            ],
            textInputAction: TextInputAction.done),
        SizedBox(height: 12.h),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            Container(
              padding:
                  getMarginOrPadding(top: 7, bottom: 7, left: 20, right: 20),
              decoration: BoxDecoration(
                color: UiConstants.whiteColor,
                borderRadius: BorderRadius.circular(63.r),
              ),
              child: SizedBox(
                height: 43.h,
                child: merchImages.isNotEmpty
                    ? ListView.separated(
                        padding: getMarginOrPadding(right: 56),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final image = merchImages[index];
                          if (image.path.isNotEmpty) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(7.r),
                              child: Image.file(
                                File(image.path),
                                fit: BoxFit.fill,
                                width: 63.w,
                                height: 43.h,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 63.w,
                                    height: 43.h,
                                    decoration: BoxDecoration(
                                      color: UiConstants.lightGreyColor,
                                      borderRadius: BorderRadius.circular(7.r),
                                    ),
                                    child: Icon(
                                      Icons.error,
                                      color: UiConstants.redColor,
                                      size: 20.w,
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            return Container(
                              width: 63.w,
                              height: 43.h,
                              decoration: BoxDecoration(
                                color: UiConstants.lightGreyColor,
                                borderRadius: BorderRadius.circular(7.r),
                              ),
                              child: Icon(
                                Icons.image_not_supported,
                                color: UiConstants.greyColor,
                                size: 20.w,
                              ),
                            );
                          }
                        },
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 10.w),
                        itemCount: merchImages.length)
                    : Container(
                        width: 63.w,
                        height: 43.h,
                        decoration: BoxDecoration(
                          color: UiConstants.lightGreyColor,
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                        child: Icon(
                          Icons.add_photo_alternate,
                          color: UiConstants.greyColor,
                          size: 20.w,
                        ),
                      ),
              ),
            ),
            Positioned(
              right: 20.w,
              child: GestureDetector(
                onTap: () async {
                  XFile? image = await Utils.pickImage();
                  if (image != null) {
                    addedImage(image);
                  }
                },
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                      color: UiConstants.lightGreyColor.withValues(alpha: .46),
                      shape: BoxShape.circle),
                  child: Icon(Icons.add_rounded,
                      size: 30.w, color: UiConstants.whiteColor),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

