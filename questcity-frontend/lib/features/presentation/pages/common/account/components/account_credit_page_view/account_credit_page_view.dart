import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/components/account_credit_page_view/components/credit_client_view.dart';

class AccountCreditPreview extends StatelessWidget {
  const AccountCreditPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
          padding: getMarginOrPadding(top: 24, bottom: 12),
          shrinkWrap: true,
          itemBuilder: (context, index) => const CreditPreviewItem(),
          separatorBuilder: (context, index) => SizedBox(height: 10.h),
          itemCount: 18),
    );
  }
}
