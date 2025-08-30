import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/data/models/quests/current_quest_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/custom_snapping_bottom_sheet/point_item.dart';

class PointsList extends StatelessWidget {
  final List<QuestPointModel> route;
  final int currentPoint;
  final int questId;
  const PointsList(
      {super.key, required this.route, required this.currentPoint, required this.questId});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
          padding: getMarginOrPadding(bottom: 13),
          shrinkWrap: true,
          itemBuilder: (context, index) => PointItem(
                pointStatus: _getPointStatus(index, currentPoint),
                index: index,
                questId: questId,
                model: route[index],
              ),
          separatorBuilder: (context, index) => SizedBox(height: 7.h),
          itemCount: route.length),
    );
  }

  PointStatus _getPointStatus(int pointIndex, int currentIndex) {
    if (pointIndex < currentIndex) {
      return PointStatus.passes;
    } else if (pointIndex > currentIndex) {
      return PointStatus.unpassed;
    } else {
      return PointStatus.current;
    }
  }
}

enum PointStatus { passes, current, unpassed }
