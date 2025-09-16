import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/data/models/quests/current_quest_model.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/custom_snapping_bottom_sheet/no_complete_point_suffix_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/custom_snapping_bottom_sheet/points_list.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/custom_snapping_bottom_sheet/right_now_view.dart';

class PointItem extends StatelessWidget {
  final QuestPointModel model;
  final int questId;
  const PointItem(
      {super.key,
      required this.pointStatus,
      required this.index,
      required this.model,
      required this.questId});

  final PointStatus pointStatus;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      color: pointStatus == PointStatus.current ? UiConstants.whiteColor.withValues(alpha: .75) : null,
      hasBlur: true,
      contentPadding: getMarginOrPadding(all: 12),
      body: Row(
        children: [
          _getPointSuffixView(),
          SizedBox(width: 10.w),
          Text(
            model.name,
            style: UiConstants.textStyle23.copyWith(
                color: pointStatus == PointStatus.current
                    ? UiConstants.black2Color
                    : UiConstants.whiteColor),
          ),
          if (pointStatus == PointStatus.current)
            RightNowView(
              model: model,
              point: index,
              questId: questId,
            )
        ],
      ),
    );
  }

  Widget _getPointSuffixView() {
    if (pointStatus == PointStatus.passes) {
      return SvgPicture.asset(Paths.checkInCircleIconPath, height: 30.w, width: 30.w);
    } else {
      return NoCompletePointSuffixView(pointStatus: pointStatus, index: index);
    }
  }
}
