import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForwardButton extends StatelessWidget {
  const ForwardButton({super.key, required this.onTap});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onTap,
      fillColor: Colors.white,
      shape: const CircleBorder(),
      constraints: BoxConstraints(
        maxWidth: 48.w,
        maxHeight: 48.w,
        minHeight: 48.w,
        minWidth: 48.w,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: const Icon(Icons.arrow_forward, color: Colors.orange),
    );
  }
}
