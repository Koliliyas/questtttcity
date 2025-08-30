import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

class EditQuestPointFilesChipByDownloadFilesBody extends StatelessWidget {
  const EditQuestPointFilesChipByDownloadFilesBody({
    super.key,
    required this.onDelete,
    required this.countFiles,
  });

  final Function() onDelete;
  final int countFiles;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (context, index) => GradientCard(
            borderRadius: 24.r,
            contentPadding:
                getMarginOrPadding(top: 15, bottom: 15, right: 20, left: 20),
            body: Row(
              children: [
                Expanded(
                  child: Text('Name of file.pdf',
                      style: UiConstants.rememberTheUser
                          .copyWith(color: UiConstants.whiteColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                        color: UiConstants.whiteColor.withValues(alpha: .46),
                        shape: BoxShape.circle),
                    child: Icon(Icons.close_rounded,
                        size: 24.w, color: UiConstants.whiteColor),
                  ),
                )
              ],
            )),
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemCount: countFiles);
  }
}
