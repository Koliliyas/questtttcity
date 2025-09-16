import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/action_panel.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/buddy_hint_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/complete_quest_gradient_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/components/toolbar.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/cubit/completing_quest_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/locator_service.dart';

class CompletingQuestScreen extends StatelessWidget {
  final int questId;
  final String questName;
  final String mileage;
  final String questImage;

  const CompletingQuestScreen({
    super.key,
    required this.questId,
    required this.questName,
    required this.mileage,
    required this.questImage,
  });

  final List<IconData> icons = const [
    Icons.message,
    Icons.call,
    Icons.mail,
    Icons.notifications,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompletingQuestScreenCubit(sl())..getData(questId),
      child: BlocBuilder<CompletingQuestScreenCubit, CompletingQuestScreenState>(
        builder: (context, state) {
          CompletingQuestScreenCubit cubit = context.read<CompletingQuestScreenCubit>();
          // ignore: deprecated_member_use
          return WillPopScope(
            onWillPop: () async {
              if (cubit.state is CompletingQuestScreenHint) {
                cubit.hideOrShowHint();
                return false;
              } else {
                return true;
              }
            },
            child: BlocConsumer<CompletingQuestScreenCubit, CompletingQuestScreenState>(
              buildWhen: (previous, current) => current is! CompletingQuestScreenHint,
              listener: (context, state) {
                if (state is CompletingQuestScreenLoaded) {
                  if (state.completed) {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              image: DecorationImage(
                                  image: AssetImage(Paths.backgroundGradient1Path),
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.high),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),
                                  Text(
                                    "You're awesome!",
                                    style: TextStyle(
                                      color: UiConstants.whiteColor,
                                      fontSize: 20.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "By going on this quest you learned a lot about the $questName, saw iconic places, relaxed and had a great time. See you at the next quest, bye!",
                                    style: TextStyle(
                                      color: UiConstants.whiteColor,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  CustomButton(
                                    onTap: () => Navigator.pop(
                                      context,
                                    ),
                                    title: "Finish the quest",
                                  ),
                                ],
                              ),
                            ),
                          );
                          // ignore: use_build_context_synchronously
                        }).then((value) => Navigator.pop(context));
                  }
                }
              },
              builder: (context, state) {
                if (state is CompletingQuestScreenLoaded) {
                  return Scaffold(
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
                                child: ActionPanel(
                                  questImage: questImage,
                                  questName: questName,
                                ),
                              ),
                              CompleteQuestGradientView(
                                body: Toolbar(
                                  cubit: cubit,
                                  questId: questId,
                                  onTapHints: cubit.hideOrShowHint,
                                  questName: questName,
                                  route: state.quest.points,
                                  mileage: mileage,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (cubit.state is CompletingQuestScreenHint)
                          BlurryContainer(
                            padding: EdgeInsets.zero,
                            borderRadius: BorderRadius.zero,
                            child: BuddyHintView(
                                onPay: cubit.hideOrShowHint, onClose: cubit.hideOrShowHint),
                          ),
                      ],
                    ),
                  );
                } else {
                  return Scaffold(
                    body: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Paths.mockCameraBackgroundPath),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
