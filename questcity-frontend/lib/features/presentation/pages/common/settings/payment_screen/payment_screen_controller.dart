import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_bottom_sheet_template/custom_bottom_sheet_template.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/payment_screen/components/add_new_card_body.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class PaymentScreenController {
  static showAddingNewCardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        height: 446,
        isBack: false,
        titleText: LocaleKeys.kTextAddingNewCard.tr(),
        isBackgroundImage: true,
        body: const AddNewCardBody(),
      ),
    );
  }
}

