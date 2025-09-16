import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/invite_friend_screen/components/exclude_friend_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/invite_friend_screen/components/invite_friend_list.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/invite_friend_screen/components/success_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/invite_friend_screen/cubit/invite_friend_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class InviteFriendScreen extends StatelessWidget {
  const InviteFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => InviteFriendCubit(),
        child: BlocBuilder<InviteFriendCubit, InviteFriendState>(
          builder: (context, state) {
            InviteFriendCubit cubit = context.read<InviteFriendCubit>();
            return Stack(
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
                BlurryContainer(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.zero,
                    child: Container()),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 24.h,
                  right: 16.w,
                  left: 16.w,
                  bottom: 60.h,
                  child: Column(
                    children: [
                      if (state is! InviteFriendInvitesSended)
                        CustomAppBar(
                            onTapBack: () => state is InviteFriendExcludeFriend
                                ? cubit.onReturnInvite()
                                : Navigator.pop(context),
                            title: LocaleKeys.kTextInviteFriend.tr()),
                      if (state is! InviteFriendInitial) const Spacer(),
                      state is InviteFriendInitial
                          ? Expanded(
                              child: Padding(
                                padding: getMarginOrPadding(top: 56.h),
                                child: InviteFriendList(
                                    onTap: cubit.onTapFriend,
                                    checkedFriendStatuses: cubit.invites),
                              ),
                            )
                          : state is InviteFriendInvitesSended
                              ? Padding(
                                  padding:
                                      getMarginOrPadding(left: 56, right: 56),
                                  child: const SuccessView(),
                                )
                              : Padding(
                                  padding:
                                      getMarginOrPadding(left: 42, right: 42),
                                  child: const ExcludeFriendView(),
                                ),
                      SizedBox(height: 66.h),
                      if (state is! InviteFriendInitial) const Spacer(),
                      if (state is InviteFriendInitial)
                        CustomButton(
                          title: LocaleKeys.kTextSendInvitation.tr(),
                          onTap: cubit.onInvitesSend,
                        ),
                      if (state is InviteFriendExcludeFriend)
                        CustomButton(
                          title: LocaleKeys.kTextExcludeFriend.tr(),
                          onTap: cubit.onExcludeFriend,
                        ),
                      if (state is InviteFriendInvitesSended)
                        CustomButton(
                          title: LocaleKeys.kTextGoBackToQuest.tr(),
                          onTap: () => Navigator.pop(context),
                        ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

