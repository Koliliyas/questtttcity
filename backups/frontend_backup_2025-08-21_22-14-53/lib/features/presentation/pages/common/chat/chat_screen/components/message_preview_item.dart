import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/custom_cache_manager.dart';
import 'package:los_angeles_quest/features/domain/entities/chat_entity.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

class MessagePreviewItem extends StatelessWidget {
  const MessagePreviewItem(
      {super.key, required this.onTap, required this.chat});

  final Function() onTap;
  final ChatEntity chat;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      onTap: onTap,
      borderRadius: 24.r,
      contentPadding:
          getMarginOrPadding(top: 10, bottom: 10, left: 16, right: 16),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25.w,
            child: CachedNetworkImage(
              width: 50.w,
              height: 50.w,
              imageUrl: chat.photoPath,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              cacheManager: CustomCacheManager(),
              errorWidget: (context, url, error) =>
                  Icon(Icons.image, size: 25.w, color: UiConstants.greyColor),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Padding(
              padding: getMarginOrPadding(top: 5, bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.username,
                    style: UiConstants.textStyle4
                        .copyWith(color: UiConstants.whiteColor),
                  ),
                  Text(
                    chat.message.msg,
                    style: UiConstants.textStyle15
                        .copyWith(color: UiConstants.lightGreyColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 25.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '8:46',
                style: UiConstants.textStyle2
                    .copyWith(color: UiConstants.greyColor),
              ),
              if (chat.message.newMessage > 0)
                Container(
                  padding: getMarginOrPadding(all: 1),
                  margin: getMarginOrPadding(top: 5),
                  height: 24.w,
                  width: 24.w,
                  decoration: const BoxDecoration(
                      color: UiConstants.orangeColor, shape: BoxShape.circle),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      chat.message.newMessage.toString(),
                      style: UiConstants.textStyle2
                          .copyWith(color: UiConstants.whiteColor, height: 1),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
