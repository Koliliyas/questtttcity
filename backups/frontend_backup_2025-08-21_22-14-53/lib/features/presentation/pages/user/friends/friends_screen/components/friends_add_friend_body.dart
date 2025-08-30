import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

import '../cubit/friends_screen_cubit.dart';

class FriendsAddFriendBody extends StatefulWidget {
  final FriendsScreenCubit cubit;
  const FriendsAddFriendBody({super.key, required this.cubit});

  @override
  State<FriendsAddFriendBody> createState() => _FriendsAddFriendBodyState();
}

class _FriendsAddFriendBodyState extends State<FriendsAddFriendBody> {
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 370 - 100,
      child: Column(
        children: [
          Text(
            LocaleKeys.kTextEnterFriendEmail.tr(),
            style:
                UiConstants.textStyle7.copyWith(color: UiConstants.whiteColor, fontFamily: 'Inter'),
          ),
          SizedBox(height: 24.h),
          CustomTextField(
            hintText: LocaleKeys.kTextEmail.tr(),
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            isExpanded: true,
            textStyle:
                UiConstants.textStyle7.copyWith(fontFamily: 'Inter', color: UiConstants.blackColor),
            fillColor: UiConstants.whiteColor,
            isTextFieldInBottomSheet: true,
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp(r'\s'),
              ),
            ],
          ),
          const Spacer(),
          CustomButton(
            title: LocaleKeys.kTextSent.tr(),
            onTap: () {
              widget.cubit.createRequest(emailController.text);
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 23.h),
        ],
      ),
    );
  }
}

