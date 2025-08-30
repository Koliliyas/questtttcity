import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageAttachment extends StatelessWidget {
  const ImageAttachment({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.asset(image, fit: BoxFit.cover, height: 65.w, width: 65.w),
    );
  }
}
