import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/features/data/models/quests/current_quest_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/see_a_map_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/custom_snapping_bottom_sheet/custom_snapping_bottom_header.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/custom_snapping_bottom_sheet/points_list.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/cubit/completing_quest_screen_cubit.dart';

class ToolsScreen extends StatelessWidget {
  final List<QuestPointModel> route;
  final String questName;
  final int questId;
  final String mileage;
  final CompletingQuestScreenCubit cubit;
  const ToolsScreen({
    super.key,
    required this.route,
    required this.questName,
    required this.mileage,
    required this.questId,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit..getCurrentPoint(questId),
      child: BlocBuilder<CompletingQuestScreenCubit, CompletingQuestScreenState>(
        buildWhen: (previous, current) => current is CompletingQuestScreenLoaded,
        builder: (context, state) {
          final loadedState = state as CompletingQuestScreenLoaded;
          return Scaffold(
              body: Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(Paths.backgroundGradient1Path),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: MapWidget(
                    route: route.map((e) => LatLng(e.place.latitude, e.place.longitude)).toList(),
                  ),
                ),
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
                        currentPoint: loadedState.currentPoint,
                        route: route,
                        questId: questId,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ));
        },
      ),
    );
  }
}
