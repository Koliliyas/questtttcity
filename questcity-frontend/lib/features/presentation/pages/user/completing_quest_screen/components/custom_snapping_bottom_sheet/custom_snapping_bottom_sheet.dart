import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/data/models/quests/current_quest_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/custom_snapping_bottom_sheet/custom_snapping_bottom_header.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/custom_snapping_bottom_sheet/points_list.dart';
import 'package:snapping_bottom_sheet/snapping_bottom_sheet.dart';

class CustomSnappingBottomSheet extends StatelessWidget {
  final List<QuestPointModel> route;
  final String questName;
  final String mileage;
  final int currentPoint;
  final int questId;
  const CustomSnappingBottomSheet({
    super.key,
    this.body,
    required this.route,
    required this.questName,
    required this.mileage,
    required this.currentPoint,
    required this.questId,
  });

  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return SnappingBottomSheet(
      elevation: 8,
      cornerRadius: 24.r,
      snapSpec: const SnapSpec(
        snap: true,
        snappings: [0.18, 0.5, 1.0],
        positioning: SnapPositioning.relativeToSheetHeight,
      ),
      body: body,
      builder: (context, state) {
        return Container(
          height: 600,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24.r),
            ),
            color: Colors.red,
            border: GradientBoxBorder(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.white.withValues(alpha: 0)],
                ),
                width: 1),
            image: const DecorationImage(
                image: AssetImage(Paths.backgroundGradient1Path),
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high),
          ),
          child: Padding(
            padding: getMarginOrPadding(top: 13, right: 16, left: 16),
            child: Column(
              children: [
                Container(
                  height: 5.h,
                  width: 43.w,
                  decoration: BoxDecoration(
                    color: UiConstants.whiteColor,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: Column(
                    children: [
                      CustomSnappingBottomHeader(
                        questName: questName,
                        mileage: mileage,
                        spots: route.length,
                      ),
                      SizedBox(height: 24.h),
                      PointsList(
                        currentPoint: currentPoint,
                        route: route,
                        questId: questId,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
