import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/data/models/user_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/account_screen.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/widgets/name_chip_under_avatar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/right_arrow_in_orange_circle.dart';

class UserItem extends StatelessWidget {
  const UserItem({super.key, required this.user, this.isBlocked = false});

  final UserModel user;
  final bool isBlocked;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        GradientCard(
          onTap: () => Navigator.push(
            context,
            FadeInRoute(
                AccountScreen(
                  user: user,
                  isAdminEditView: true,
                ),
                Routes.accountScreen),
          ),
          borderRadius: 26.r,
          contentPadding: getMarginOrPadding(
              left: 16, right: isBlocked ? 16 : 55, bottom: 16, top: 16),
          body: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25.w,
                    child: ClipOval(
                      child: Image.asset(
                        Paths.avatarPath,
                        fit: BoxFit.cover,
                        width: 50.w,
                        height: 50.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  isBlocked
                      ? Flexible(
                          child: Text(
                            '${user.firstName} ${user.lastName}',
                            style: UiConstants.textStyle16.copyWith(
                                color: UiConstants.whiteColor,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : Flexible(
                          child: Text(
                            '${user.firstName} ${user.lastName}',
                            style: UiConstants.textStyle16.copyWith(
                                color: UiConstants.whiteColor,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                  SizedBox(width: 10.w),
                  if (!isBlocked)
                    NameChipUnderAvatar(
                      role: Utils.convertServerRoleToEnumItem(user.role),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (!isBlocked)
          Positioned(
            right: 16.w,
            child: RightArrowInOrangeCircle(
              onTap: !isBlocked
                  ? () => Navigator.push(
                        context,
                        FadeInRoute(
                            AccountScreen(
                              user: user,
                              isAdminEditView: true,
                            ),
                            Routes.accountScreen),
                      )
                  : () {},
            ),
          )
        else
          Positioned(
            right: 16.w,
            child: Container(
              padding:
                  getMarginOrPadding(top: 6, bottom: 6, right: 12, left: 12),
              decoration: BoxDecoration(
                color: UiConstants.redColor,
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: Text(
                LocaleKeys.kTextUnlock.tr(),
                style: UiConstants.rememberTheUser
                    .copyWith(color: UiConstants.whiteColor),
              ),
            ),
          )
      ],
    );
  }
}

