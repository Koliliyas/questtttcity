import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class VideoAttachment extends StatelessWidget {
  const VideoAttachment({super.key, required this.video});

  final String video;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(video, fit: BoxFit.cover, height: 65.w, width: 65.w),
          Icon(Icons.play_circle_rounded,
              color: UiConstants.whiteColor, size: 36.w)
        ],
      ),
    );
  }
}
