import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/components/address_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/components/choose_card_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/components/order_inventory_body.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_bottom_sheet_template/custom_bottom_sheet_template.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class QuestScreenController {
  static addressSheet(BuildContext context, Function() buyQuest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        height: 297,
        isBackgroundImage: true,
        isBack: false,
        titleText: 'Adress',
        body: AddressBody(
          onButtonTap: () async {
            Navigator.pop(context);
            await Future.delayed(
              const Duration(milliseconds: 200),
            );
            if (context.mounted) {
              chooseCardSheet(context, buyQuest);
            }
          },
        ),
      ),
    );
  }

  static chooseCardSheet(BuildContext context, Function() onBuyQuest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        height: 390,
        isBackgroundImage: true,
        isBack: true,
        onTapBack: () async {
          Navigator.pop(context);
          await Future.delayed(
            const Duration(milliseconds: 200),
          );
          if (context.mounted) {
            addressSheet(context, onBuyQuest);
          }
        },
        titleText: LocaleKeys.kTextChooseTheCard.tr(),
        body: ChooseCardBody(
          onButtonTap: () {
            onBuyQuest();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  static orderInventorySheet(BuildContext context, List<MerchItem> merchItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
          height: 508,
          isBackgroundImage: true,
          isBack: false,
          titleText: 'Order inventory',
          body: PageView(
            children: List.generate(merchItem.length, (index) {
              return OrderInventoryBody(
                onButtonTap: () => QuestScreenController.addressSheet(context, () {}),
                merchItem: merchItem[index],
              );
            }),
          )
          //TextField(decoration: InputDecoration(hintText: ''),),
          ),
    );
  }
}

