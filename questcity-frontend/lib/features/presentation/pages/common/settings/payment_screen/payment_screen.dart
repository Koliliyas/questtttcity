import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/payment_screen/components/card_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/payment_screen/cubit/payment_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/payment_screen/payment_screen_controller.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentScreenCubit(),
      child: BlocBuilder<PaymentScreenCubit, PaymentScreenState>(
        builder: (context, state) {
          //PaymentScreenCubit cubit = context.read<PaymentScreenCubit>();
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Paths.backgroundGradient1Path),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high),
              ),
              child: Padding(
                padding: getMarginOrPadding(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 16,
                    right: 16,
                    bottom: 12),
                child: Column(
                  children: [
                    CustomAppBar(
                      onTapBack: () => Navigator.pop(context),
                      title: LocaleKeys.kTextPayment.tr(),
                      action: GestureDetector(
                        onTap: () =>
                            PaymentScreenController.showAddingNewCardSheet(
                                context),
                        child: Container(
                          width: 53.w,
                          height: 53.w,
                          decoration: const BoxDecoration(
                              color: UiConstants.whiteColor,
                              shape: BoxShape.circle),
                          padding: getMarginOrPadding(all: 16),
                          child: SvgPicture.asset(Paths.addIconPath),
                        ),
                      ),
                    ),
                    SizedBox(height: 39.h),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          const CardView(
                              backgroundImage: Paths.backgroundGradient2Path),
                          SizedBox(height: 12.h),
                          const CardView(
                              backgroundImage: Paths.backgroundGradient3Path),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

