import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/domain/entities/message_entity.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/components/audio_player_widget.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/components/image_attachment.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/components/video_attachment.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/internal_chat_screen/components/triangle_painter.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class SupportChatMessageText extends StatelessWidget {
  const SupportChatMessageText(
      {super.key, required this.message, required this.usernamePanther});

  final MessageEntity message;
  final String usernamePanther;

  @override
  Widget build(BuildContext context) {
    bool isLeftSideMessage() {
      return !message.isMe!;
    }

    return Expanded(
      child: Stack(
        children: [
          Container(
            margin: getMarginOrPadding(
              right: isLeftSideMessage() ? 60.w : 5.w,
              left: isLeftSideMessage() ? 5.w : 60.w,
            ),
            padding: getMarginOrPadding(all: 12),
            decoration: BoxDecoration(
              color: !message.isMe!
                  ? UiConstants.darkViolet2Color
                  : UiConstants.lightViolet3Color,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.isMe! ? LocaleKeys.kTextYou.tr() : usernamePanther,
                  style: UiConstants.textStyle7.copyWith(
                      fontWeight: FontWeight.w500,
                      color: !message.isMe!
                          ? UiConstants.whiteColor
                          : UiConstants.blackColor),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      message.msg,
                      style: UiConstants.textStyle2.copyWith(
                          fontWeight: FontWeight.w400,
                          color: !message.isMe!
                              ? UiConstants.whiteColor
                              : UiConstants.blackColor),
                    ),
                    Text(
                      Utils.formatTimestamp(int.parse(message.timestampSend!)),
                      style: UiConstants.textStyle15.copyWith(
                          color: !message.isMe!
                              ? UiConstants.whiteColor
                              : UiConstants.blackColor),
                    ),
                  ],
                ),
                if (!message.isMe!)
                  Wrap(
                    spacing: 7.5.w,
                    runSpacing: 7.5.w,
                    children: [
                      const ImageAttachment(image: Paths.category1Path),
                      const VideoAttachment(video: Paths.category2Path),
                      AudioPlayerWidget(key: UniqueKey()),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 5,
            right: isLeftSideMessage() ? null : 0,
            left: !(isLeftSideMessage()) ? null : 0,
            child: SizedBox(
              height: 12.h,
              width: 25.5.w,
              child: CustomPaint(
                painter: TrianglePainter(
                    color: !message.isMe!
                        ? UiConstants.darkViolet2Color
                        : UiConstants.lightViolet3Color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

