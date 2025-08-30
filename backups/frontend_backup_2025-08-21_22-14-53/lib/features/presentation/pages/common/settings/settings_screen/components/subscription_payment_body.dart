import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

class SubscriptionPaymentBody extends StatefulWidget {
  const SubscriptionPaymentBody({super.key});

  @override
  State<SubscriptionPaymentBody> createState() =>
      _SubscriptionPaymentBodyState();
}

class _SubscriptionPaymentBodyState extends State<SubscriptionPaymentBody> {
  int checkedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SubscriptionPaymentBodyItem(
          isChecked: checkedIndex == 0,
          icon: Paths.googlePayIconPath,
          onTap: () => setState(() {
            checkedIndex = 0;
          }),
        ),
        SizedBox(height: 12.h),
        SubscriptionPaymentBodyItem(
          isChecked: checkedIndex == 1,
          icon: Paths.visaIconPath,
          onTap: () => setState(() {
            checkedIndex = 1;
          }),
        ),
        SizedBox(height: 12.h),
        SubscriptionPaymentBodyItem(
          isChecked: checkedIndex == 2,
          icon: Paths.mastercardIconPath,
          onTap: () => setState(() {
            checkedIndex = 2;
          }),
        ),
        SizedBox(height: 12.h),
        SubscriptionPaymentBodyItem(
          isChecked: checkedIndex == 3,
          icon: Paths.appleIconPath,
          onTap: () => setState(() {
            checkedIndex = 3;
          }),
        ),
        SizedBox(height: 12.h),
        SubscriptionPaymentBodyItem(
          isChecked: checkedIndex == 4,
          icon: Paths.paypalIconPath,
          onTap: () => setState(() {
            checkedIndex = 4;
          }),
        ),
      ],
    );
  }
}

class SubscriptionPaymentBodyItem extends StatelessWidget {
  const SubscriptionPaymentBodyItem(
      {super.key,
      required this.isChecked,
      required this.icon,
      required this.onTap});

  final bool isChecked;
  final String icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      onTap: onTap,
      height: 65.h,
      contentPadding: getMarginOrPadding(all: 16),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isChecked)
            Padding(
              padding: getMarginOrPadding(right: 20),
              child: SvgPicture.asset(Paths.ckeckInCircleIconPath,
                  width: 24.w, height: 24.w),
            ),
          Image.asset(icon),
        ],
      ),
    );
  }
}
