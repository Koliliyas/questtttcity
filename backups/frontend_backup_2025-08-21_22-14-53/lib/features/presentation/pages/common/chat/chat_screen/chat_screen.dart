import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/chat_screen/components/messages_preview_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/chat_screen/cubit/chat_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/chat_screen/cubit/chat_screen_state.dart';
import 'package:los_angeles_quest/features/presentation/widgets/blur_rectangle_view.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_loading_indicator.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_search_view.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, this.isQuestChat = false});

  final bool isQuestChat;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
              onPressed: () =>
                  context.read<ChatScreenCubit>().sendMessage('РџСЂРёРІРµС‚')),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(Paths.backgroundGradient1Path),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high),
            ),
            child: BlocBuilder<ChatScreenCubit, ChatScreenState>(
              builder: (context, state) {
                ChatScreenCubit cubit = context.read<ChatScreenCubit>();

                if (state is ChatScreenLoading) {
                  return const CustomLoadingIndicator();
                } else if (state is ChatScreenError) {
                  return Text(
                    state.message,
                    style: const TextStyle(color: Colors.black, fontSize: 25),
                  );
                }
                //ChatScreenLoaded _state = (state as ChatScreenLoaded);
                return Stack(
                  children: [
                    Padding(
                      padding: getMarginOrPadding(
                          top: MediaQuery.of(context).padding.top + 24,
                          left: 16,
                          right: 16),
                      child: Column(
                        children: [
                          if (!isQuestChat)
                            Padding(
                              padding: getMarginOrPadding(bottom: 16),
                              child: CustomSearchView(
                                controller: cubit.searchController,
                                options: const [
                                  'Los Angeles',
                                  'San Francisco',
                                  'New York',
                                  'Chicago'
                                ],
                                // suffixWidget: homeCubit.role == Role.MANAGER
                                //     ? NotificationView(
                                //         onTap: () => Navigator.push(
                                //           context,
                                //           FadeInRoute(
                                //               const RequestsForCreditsScreen(),
                                //               Routes.requestsForCreditsScreen),
                                //         ),
                                //       )
                                //     : null,
                              ),
                            )
                          else
                            Padding(
                              padding: getMarginOrPadding(bottom: 24),
                              child: CustomAppBar(
                                onTapBack: () => Navigator.pop(context),
                                title: LocaleKeys.kTextChats.tr(),
                              ),
                            ),
                          RefreshIndicator(
                            onRefresh: cubit.getChats,
                            child: MessagesPreviewView(
                                isQuestChat: isQuestChat, chats: cubit.chats),
                          ),
                        ],
                      ),
                    ),
                    const BlurRectangleView()
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
