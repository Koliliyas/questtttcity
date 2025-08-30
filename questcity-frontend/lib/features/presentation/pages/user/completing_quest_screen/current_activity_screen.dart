import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/data/models/quests/current_quest_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/buddy_hint_view.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/cubit/completing_quest_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/orbital_radar_screen/components/hint_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/locator_service.dart';

import 'components/current_activity/current_activity.dart';

class CurrentActivityScreen extends StatefulWidget {
  final QuestPointModel activityType;
  final int questId;
  final int point;
  const CurrentActivityScreen({
    super.key,
    required this.activityType,
    required this.questId,
    required this.point,
  });

  @override
  State<CurrentActivityScreen> createState() => _CurrentActivityScreenState();
}

class _CurrentActivityScreenState extends State<CurrentActivityScreen> {
  bool isFirstStep = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompletingQuestScreenCubit(sl())
        ..getCurrentActivity(widget.activityType, widget.point, widget.questId),
      child: BlocBuilder<CompletingQuestScreenCubit, CompletingQuestScreenState>(
        builder: (context, state) {
          CompletingQuestScreenCubit cubit = context.read<CompletingQuestScreenCubit>();
          if (cubit.state is CompletingQuestScreenActivity) {
            final state = cubit.state as CompletingQuestScreenActivity;

            // ignore: deprecated_member_use
            return WillPopScope(
              onWillPop: () async {
                if (state.isHintShow) {
                  cubit.hideOrShowHint();
                  return false;
                } else {
                  return true;
                }
              },
              child: Scaffold(
                body: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Paths.mockCameraBackgroundPath),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high),
                      ),
                    ),
                    Padding(
                      padding: getMarginOrPadding(top: MediaQuery.of(context).padding.top + 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: getMarginOrPadding(left: 16, right: 16),
                            child: CustomAppBar(
                              onTapBack: () {
                                Navigator.popUntil(
                                  context,
                                  ModalRoute.withName(
                                    Routes.completingQuestScreen,
                                  ),
                                );
                              },
                              title: state.activityType.name,
                              action: HintButton(onTap: () {
                                cubit.hideOrShowHint();
                              }),
                            ),
                          ),
                          if (isFirstStep || state.isCompleted)
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (!state.isCompleted)
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: BlurryContainer(
                                                child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withAlpha(80),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Description',
                                                    style: UiConstants.textStyle1.copyWith(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.normal),
                                                  ),
                                                  Text(
                                                    widget.activityType.description,
                                                    style: UiConstants.textStyle4
                                                        .copyWith(color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ),
                                        Align(
                                          alignment: const Alignment(-0.6, 0),
                                          child: Stack(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white.withValues(alpha: 0.5),
                                                      spreadRadius: -5,
                                                      blurRadius: 40,
                                                      offset: const Offset(0, 0),
                                                    ),
                                                  ],
                                                ),
                                                child: Image.asset(
                                                  state.activityType.initialImage,
                                                  height: 200,
                                                  width: 200,
                                                  scale: 0.5,
                                                ),
                                              ),
                                              if (state.isCompleted)
                                                Align(
                                                  alignment: const Alignment(-0.2, 0),
                                                  child: Image.asset(
                                                    Paths.bigCheckInCircle,
                                                    height: 80,
                                                    width: 80,
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!state.isCompleted) ...[
                                    const SizedBox(
                                      height: 60,
                                    ),
                                    CustomButton(
                                      title: state.activityType.initialAction,
                                      onTap: () {
                                        setState(() {
                                          isFirstStep = false;
                                        });
                                      },
                                    ),
                                  ]
                                ],
                              ),
                            ))
                          else if (!state.isCompleted)
                            Expanded(
                              child: BlocBuilder<CompletingQuestScreenCubit,
                                  CompletingQuestScreenState>(builder: (context, state) {
                                if (state is CompletingQuestScreenActivity) {
                                  switch (state.activityType) {
                                    case final QrCodeActivity model:
                                      return QrCode(
                                        activityModel: model,
                                      );
                                    case final CombinationLockerActivity model:
                                      return CombinationLocker(activityModel: model);
                                    case final PhotoActivity model:
                                      return Photo(activityModel: model);
                                    case final FileActivity model:
                                      return FileActivityScreen(activityModel: model);
                                    case final WordActivity model:
                                      return Word(activityModel: model);
                                  }
                                }
                                return const SizedBox();
                              }),
                            ),
                        ],
                      ),
                    ),
                    if (state.isHintShow)
                      BlurryContainer(
                        padding: EdgeInsets.zero,
                        borderRadius: BorderRadius.zero,
                        child: BuddyHintView(
                            onPay: cubit.hideOrShowHint, onClose: cubit.hideOrShowHint),
                      ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
