import 'package:flutter/material.dart';
import 'package:los_angeles_quest/features/domain/entities/message_entity.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/components/support_chat_message_text.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/components/support_message_avatar.dart';

class SupportChatMessage extends StatelessWidget {
  const SupportChatMessage(
      {super.key, required this.message, required this.usernamePanther});

  final MessageEntity message;
  final String usernamePanther;

  @override
  Widget build(BuildContext context) {
    bool isLeftSideMessage() {
      return !message.isMe!;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: isLeftSideMessage()
          ? [
              SupportMessageAvatar(isSupportMessage: !message.isMe!),
              SupportChatMessageText(
                  message: message, usernamePanther: usernamePanther)
            ]
          : [
              SupportChatMessageText(
                  message: message, usernamePanther: usernamePanther),
              SupportMessageAvatar(isSupportMessage: !message.isMe!),
            ],
    );
  }
}
