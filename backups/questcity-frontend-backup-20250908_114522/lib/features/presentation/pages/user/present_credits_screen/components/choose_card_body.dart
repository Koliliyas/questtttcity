import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/payment_screen/components/card_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/settings_screen_controller.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class ChooseCardBody extends StatefulWidget {
  const ChooseCardBody(
      {super.key,
      required this.onButtonTap,
      required this.creditsCount,
      required this.creditsAction});

  final CreditsActions creditsAction;
  final Function() onButtonTap;
  final int creditsCount;

  @override
  State<ChooseCardBody> createState() => _ChooseCardBodyState();
}

class _ChooseCardBodyState extends State<ChooseCardBody> {
  int selectedCardIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (widget.creditsAction == CreditsActions.BUY ? 376 : 466) - 100,
      child: Column(
        children: [
          if (widget.creditsAction != CreditsActions.BUY)
            Padding(
              padding: getMarginOrPadding(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25.w,
                        child: ClipOval(
                          child: Image.asset(
                            widget.creditsAction == CreditsActions.PRESENT
                                ? Paths.avatarPath
                                : Paths.quest2Path,
                            fit: BoxFit.cover,
                            width: 50.w,
                            height: 50.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        padding: getMarginOrPadding(top: 3.5, bottom: 3.5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tomas Andersen',
                              style: UiConstants.textStyle4
                                  .copyWith(color: UiConstants.whiteColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${widget.creditsCount} credits',
                              style: UiConstants.textStyle7.copyWith(
                                  color: UiConstants.orangeColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 10.w),
                  Container(
                    width: MediaQuery.of(context).size.width / 2.5,
                    padding: getMarginOrPadding(
                        top: 17.5, bottom: 17.5, left: 39, right: 30),
                    decoration: BoxDecoration(
                      color: UiConstants.whiteColor,
                      borderRadius: BorderRadius.circular(63.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '\$${widget.creditsCount}',
                            style: UiConstants.textStyle13.copyWith(
                                color: widget.creditsAction ==
                                        CreditsActions.EXCHANGE
                                    ? UiConstants.greyColor
                                    : UiConstants.blackColor,
                                decoration: widget.creditsAction ==
                                        CreditsActions.EXCHANGE
                                    ? TextDecoration.lineThrough
                                    : null),
                          ),
                        ),
                        if (widget.creditsAction == CreditsActions.EXCHANGE)
                          SizedBox(width: 10.w),
                        if (widget.creditsAction == CreditsActions.EXCHANGE)
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '\$${widget.creditsCount - 1}',
                                style: UiConstants.textStyle14
                                    .copyWith(color: UiConstants.blackColor),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                  //Expanded(
                  //  child: CustomTextField(
                  //      hintText: '\$10000',
                  //      controller: TextEditingController(text: '\$100000000'),
                  //      textAlign: TextAlign.center,
                  //      isEnabled: false,
                  //      isExpanded: true,
                  //      textStyle: UiConstants.textStyle12
                  //          .copyWith(color: UiConstants.blackColor),
                  //      fillColor: UiConstants.whiteColor,
                  //      isTextFieldInBottomSheet: true),
                  //),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                CardView(
                  height: 75,
                  backgroundImage: Paths.backgroundGradient2Path,
                  isChecked: selectedCardIndex == 0,
                  onTap: () => setState(
                    () {
                      selectedCardIndex = 0;
                    },
                  ),
                ),
                SizedBox(height: 8.h),
                CardView(
                  height: 75,
                  backgroundImage: Paths.backgroundGradient3Path,
                  isChecked: selectedCardIndex == 1,
                  onTap: () => setState(
                    () {
                      selectedCardIndex = 1;
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          CustomButton(
              title: widget.creditsAction == CreditsActions.BUY
                  ? LocaleKeys.kTextBuy.tr()
                  : widget.creditsAction == CreditsActions.EXCHANGE
                      ? LocaleKeys.kTextPurchase.tr()
                      : LocaleKeys.kTextSentToFriend.tr(),
              onTap: widget.onButtonTap),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}

