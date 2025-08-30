import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/components/account_credit_page_view/account_credit_page_view.dart';
import 'package:los_angeles_quest/features/presentation/widgets/blur_rectangle_view.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_search_view.dart';

class RequestsForCreditsScreen extends StatelessWidget {
  const RequestsForCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                  right: 16),
              child: Column(
                children: [
                  CustomAppBar(
                    onTapBack: () => Navigator.pop(context),
                    title: LocaleKeys.kTextRequestsForCredits.tr(),
                    action: null,
                  ),
                  SizedBox(height: 14.h),
                  Expanded(
                    child: Column(
                      children: [
                        CustomSearchView(
                          controller: TextEditingController(),
                          options: const [
                            'Los Angeles',
                            'San Francisco',
                            'New York',
                            'Chicago'
                          ],
                        ),
                        const AccountCreditPreview(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const BlurRectangleView()
        ],
      ),
    );
  }
}

