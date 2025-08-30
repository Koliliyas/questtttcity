import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/payment_screen/components/card_view.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class ChooseCardBody extends StatefulWidget {
  const ChooseCardBody({
    super.key,
    required this.onButtonTap,
  });

  final Function() onButtonTap;

  @override
  State<ChooseCardBody> createState() => _ChooseCardBodyState();
}

class _ChooseCardBodyState extends State<ChooseCardBody> {
  int selectedCardIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: Column(
        children: [
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
              title: '${LocaleKeys.kTextBuy.tr()} \$15',
              onTap: widget.onButtonTap),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}

