import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/account_screen.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/widgets/right_arrow_in_orange_circle.dart';

class CreditPreviewItem extends StatelessWidget {
  const CreditPreviewItem({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      onTap: () => Navigator.push(
        context,
        FadeInRoute(
            const AccountScreen(
              isAdminEditView: true,
              isCreditView: true,
            ),
            Routes.accountScreen),
      ),
      borderRadius: 24.r,
      contentPadding:
          getMarginOrPadding(top: 10, bottom: 10, left: 16, right: 16),
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
              Expanded(
                child: Padding(
                  padding: getMarginOrPadding(top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tomas Andersen',
                        style: UiConstants.textStyle4
                            .copyWith(color: UiConstants.whiteColor),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${LocaleKeys.kText3Requests.tr(args: [
                                    '3'
                                  ])} ",
                              style: UiConstants.requestForCredits
                                  .copyWith(color: UiConstants.orangeColor),
                            ),
                            TextSpan(
                              text: LocaleKeys.kTextForCredits.tr(),
                              style: UiConstants.requestForCredits
                                  .copyWith(color: UiConstants.whiteColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 25.w),
              RightArrowInOrangeCircle(
                onTap: () => Navigator.push(
                  context,
                  FadeInRoute(
                      const AccountScreen(
                        isAdminEditView: true,
                        isCreditView: true,
                      ),
                      Routes.accountScreen),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

