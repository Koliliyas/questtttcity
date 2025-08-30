import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';

class SupportMessageAvatar extends StatelessWidget {
  const SupportMessageAvatar({super.key, this.isSupportMessage = false});

  final bool isSupportMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34.w,
      width: 34.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
            !isSupportMessage
                ? Paths.backgroundGradient2Path
                : Paths.avatarPath,
            fit: BoxFit.cover,
            width: 34.w,
            height: 34.w),
      ),
    );
  }
}
