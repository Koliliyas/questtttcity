import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/domain/entities/chat_entity.dart'
    as ce;
import 'package:los_angeles_quest/features/domain/entities/message_entity.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/account_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/cubit/internal_chat_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/cubit/internal_chat_screen_state.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/components/support_chat_message.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/components/support_chat_text_field.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_loading_indicator.dart';
import 'package:los_angeles_quest/locator_service.dart';

class InternalChatScreen extends StatefulWidget {
  const InternalChatScreen({super.key, this.isQuestChat = false, this.chat});

  final bool isQuestChat;
  final ce.ChatEntity? chat;

  @override
  State<InternalChatScreen> createState() => _InternalChatScreenState();
}

class _InternalChatScreenState extends State<InternalChatScreen> {
  final scrollController = ScrollController();
  bool isFirstFetch = true;

  void setupScrollController(BuildContext context) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge &&
          !context.read<InternalChatScreenCubit>().isMessagesOver) {
        if (scrollController.position.pixels == 0) {
          context.read<InternalChatScreenCubit>().loadMessages();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        HomeScreenCubit homeCubit = context.read<HomeScreenCubit>();
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(Paths.backgroundGradient1Path),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high),
            ),
            child: BlocProvider(
              create: (context) => InternalChatScreenCubit(
                  getChatMessages: sl(), chatId: widget.chat!.idChat)
                ..loadMessages(),
              child:
                  BlocBuilder<InternalChatScreenCubit, InternalChatScreenState>(
                builder: (context, state) {
                  //InternalChatScreenCubit cubit =
                  //    context.read<InternalChatScreenCubit>();

                  List<MessageEntity> messages = [];
                  bool isLoading = false;

                  if (state is InternalChatScreenLoading &&
                      state.isFirstFetch) {
                    return const CustomLoadingIndicator();
                  } else if (state is InternalChatScreenLoading) {
                    messages = state.oldMessagesList;
                    isLoading = true;
                  } else if (state is InternalChatScreenLoaded) {
                    messages = state.messageList;
                  } else if (state is InternalChatScreenError) {
                    return Text(
                      state.message,
                      style: const TextStyle(color: Colors.black, fontSize: 25),
                    );
                  }

                  if (isFirstFetch) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) {
                        isFirstFetch = false;
                        scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(seconds: 1),
                            curve: Curves.ease);
                      },
                    );
                  }

                  setupScrollController(context);

                  return Padding(
                    padding: getMarginOrPadding(
                        top: MediaQuery.of(context).padding.top + 20,
                        left: 16,
                        right: 16,
                        bottom: 54),
                    child: Column(
                      children: [
                        CustomAppBar(
                          onTapBack: () => Navigator.pop(context),
                          title: widget.chat?.username ?? '',
                          action: GestureDetector(
                            onTap: () => homeCubit.role == Role.MANAGER
                                ? Navigator.push(
                                    context,
                                    FadeInRoute(
                                        const AccountScreen(
                                          isAdminEditView: false,
                                        ),
                                        Routes.accountScreen),
                                  )
                                : null,
                            child: CircleAvatar(
                              radius: 53.w / 2,
                              child: ClipOval(
                                child: Image.asset(
                                  Paths.avatarPath,
                                  fit: BoxFit.cover,
                                  width: 53.w,
                                  height: 53.w,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: ListView.separated(
                              padding: getMarginOrPadding(top: 10, bottom: 29),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                if (isLoading && index == 0) {
                                  return const CustomLoadingIndicator();
                                }
                                int realIndex = index - (isLoading ? 1 : 0);
                                final currentMessage = messages[realIndex];

                                DateTime? previousMessageTime;
                                if (realIndex > 0) {
                                  previousMessageTime =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(messages[realIndex - 1]
                                                  .timestampSend!) *
                                              1000);
                                }

                                final currentMessageTime =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(
                                                currentMessage.timestampSend!) *
                                            1000);

                                bool shouldShowDate = false;

                                if (previousMessageTime != null) {
                                  // Проверяем, меняется ли день между предыдущим и текущим сообщением
                                  if (previousMessageTime.day !=
                                          currentMessageTime.day ||
                                      previousMessageTime.month !=
                                          currentMessageTime.month ||
                                      previousMessageTime.year !=
                                          currentMessageTime.year) {
                                    shouldShowDate = true;
                                  }
                                } else {
                                  shouldShowDate =
                                      true; // Если это первое сообщение
                                }

                                return Column(
                                  children: [
                                    if (shouldShowDate)
                                      Padding(
                                        padding: getMarginOrPadding(bottom: 35),
                                        child: Text(
                                          Utils.formatDateMMMMd(
                                              currentMessageTime),
                                          style: UiConstants.textStyle10
                                              .copyWith(
                                                  color:
                                                      UiConstants.whiteColor),
                                        ),
                                      ),
                                    SupportChatMessage(
                                      message: currentMessage,
                                      usernamePanther:
                                          widget.chat?.username ?? '',
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 23.h),
                              itemCount: messages.length + (isLoading ? 1 : 0),
                              controller: scrollController,
                            ),
                          ),
                        ),
                        widget.isQuestChat
                            ? CustomButton(
                                title: 'Go back to the quest',
                                onTap: () => Navigator.popUntil(
                                  context,
                                  (Route<dynamic> route) {
                                    return route.settings.name ==
                                        Routes.completingQuestScreen;
                                  },
                                ),
                              )
                            : const SupportChatTextField()
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
