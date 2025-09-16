import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompleteQuestGradientView extends StatelessWidget {
  const CompleteQuestGradientView({super.key, this.body});

  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 448.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4A1176).withValues(alpha: 0),
                  const Color(0xFF352343).withValues(alpha: .72),
                  const Color(0xFF261B2F).withValues(alpha: .92),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4A1176).withValues(alpha: 0),
                  const Color(0xFF352343).withValues(alpha: 0),
                  const Color(0xFF261B2F).withValues(alpha: .92),
                ],
              ),
            ),
          ),
          body ?? Container()
        ],
      ),
    );
  }
}
