import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/domain/entities/chat_entity.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/chat_screen/components/message_preview_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/internal_chat_screen.dart';

class MessagesPreviewView extends StatelessWidget {
  const MessagesPreviewView(
      {super.key, this.isQuestChat = false, required this.chats});

  final bool isQuestChat;
  final List<ChatEntity> chats;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: getMarginOrPadding(bottom: 156),
        shrinkWrap: true,
        itemBuilder: (context, index) => MessagePreviewItem(
              onTap: () => Navigator.push(
                context,
                FadeInRoute(
                    InternalChatScreen(
                      isQuestChat: isQuestChat,
                      chat: chats[index],
                    ),
                    Routes.internalChatScreen),
              ),
              chat: chats[index],
            ),
        separatorBuilder: (context, index) => SizedBox(height: 10.h),
        itemCount: chats.length);
  }
}
