import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/components/statistics_card_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/components/statistics_card_header.dart';

class StatisticsCard extends StatefulWidget {
  const StatisticsCard(
      {super.key, this.isDropdown = false, this.isCategoryCard = false});

  final bool isDropdown;
  final bool isCategoryCard;

  @override
  State<StatisticsCard> createState() => _StatisticsCardState();
}

class _StatisticsCardState extends State<StatisticsCard> {
  bool isExpanded = false;

  @override
  void initState() {
    if (!widget.isDropdown) {
      isExpanded = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getMarginOrPadding(
          left: 10, right: 10, top: 10, bottom: isExpanded ? 16 : 10),
      decoration: BoxDecoration(
        color: UiConstants.whiteColor.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 12.7,
            color: UiConstants.black2Color.withValues(alpha: .25),
          ),
        ],
      ),
      child: Column(
        children: [
          StatisticsCardHeader(
              isExpanded: isExpanded,
              isDropdown: widget.isDropdown,
              onExpandedOrCollapsed: () => setState(() {
                    isExpanded = !isExpanded;
                  }),
              isCategoryCard: widget.isCategoryCard),
          Visibility(
            visible: isExpanded,
            child: const StatisticsCardBody(),
          ),
        ],
      ),
    );
  }
}
