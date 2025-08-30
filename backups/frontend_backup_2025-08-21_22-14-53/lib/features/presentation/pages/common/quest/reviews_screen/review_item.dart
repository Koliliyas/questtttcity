import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_model.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class ReviewItem extends StatelessWidget {
  const ReviewItem({super.key, this.hasAnswer = false, required this.review});
  final Review review;
  final bool hasAnswer;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        HomeScreenCubit homeCubit = context.read<HomeScreenCubit>();
        return ReviewTemplate(
          sender: homeCubit.role != Role.USER ? 'Tom Tomas' : null,
          date: review.date,
          message: review.text,
          replyWidget: homeCubit.role != Role.USER
              ? hasAnswer
                  ? const ReplyView()
                  : const ReplyButtonView()
              : null,
        );
      },
    );
  }
}

class ReviewTemplate extends StatelessWidget {
  const ReviewTemplate(
      {super.key, this.replyWidget, this.sender, required this.date, required this.message});

  final String? sender;
  final String date;
  final String message;
  final Widget? replyWidget;

  @override
  Widget build(BuildContext context) {
    double sizeAvatar = sender == LocaleKeys.kTextManager.tr() ? 32.w : 55.w;
    return GradientCard(
      borderRadius: 24.r,
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align avatar to top
            children: [
              CircleAvatar(
                radius: sizeAvatar / 2,
                child: ClipOval(
                  child: Image.asset(
                    sender != LocaleKeys.kTextManager.tr()
                        ? Paths.avatarPath
                        : Paths.backgroundGradient2Path,
                    fit: BoxFit.cover,
                    width: sizeAvatar,
                    height: sizeAvatar,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (sender != null)
                          Text(
                            sender ?? '',
                            style:
                                UiConstants.textStyle22.copyWith(color: UiConstants.lightGreyColor),
                          ),
                        Text(
                          date,
                          style:
                              UiConstants.textStyle22.copyWith(color: UiConstants.lightGreyColor),
                        ),
                      ],
                    ),
                    Text(
                      message,
                      style: UiConstants.textStyle23.copyWith(
                        color: UiConstants.whiteColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          replyWidget ?? Container(),
        ],
      ),
    );
  }
}

class ReplyView extends StatelessWidget {
  const ReplyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: getMarginOrPadding(left: 77, top: 10),
      child: ReviewTemplate(
        sender: LocaleKeys.kTextManager.tr(),
        date: '11/25/2023',
        message: 'Thank you very much, Tom!',
      ),
    );
  }
}

class ReplyButtonView extends StatelessWidget {
  const ReplyButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: getMarginOrPadding(top: 2),
          padding: getMarginOrPadding(top: 5, bottom: 5, left: 20, right: 20),
          decoration: BoxDecoration(
            color: UiConstants.whiteColor,
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Row(
            children: [
              Text(
                LocaleKeys.kTextReply.tr(),
                style: UiConstants.rememberTheUser.copyWith(
                  color: UiConstants.black2Color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 10.w),
              SvgPicture.asset(
                Paths.replyMessageIcon,
                width: 24.w,
                height: 24.w,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

