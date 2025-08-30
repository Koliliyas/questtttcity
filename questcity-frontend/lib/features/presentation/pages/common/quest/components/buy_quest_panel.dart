import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/components/add_favotire_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/components/bag_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/completing_quest_screen.dart';

class BuyQuestPanel extends StatelessWidget {
  final List<MerchItem> merchItem;
  final int? price;
  final int questId;
  final String mileage;
  final String questName;
  final String questImage;
  const BuyQuestPanel(
      {super.key,
      required this.questId,
      required this.isQuestPurchased,
      required this.onBuyQuest,
      required this.merchItem,
      this.price,
      required this.mileage,
      required this.questName,
      required this.questImage});

  final bool isQuestPurchased;
  final Function() onBuyQuest;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: getMarginOrPadding(right: 16),
          child: const AddToFavoriteButton(),
        ),
        Expanded(
          child: CustomButton(
              title: isQuestPurchased ? 'Get started' : 'Buy \$$price',
              onTap: () => isQuestPurchased
                  ? Navigator.push(
                      context,
                      FadeInRoute(
                          CompletingQuestScreen(
                            questId: questId,
                            mileage: mileage,
                            questName: questName,
                            questImage: questImage,
                          ),
                          Routes.completingQuestScreen))
                  : () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('not purchased')));
                    },
              hasGradient: false),
        ),
        Padding(
          padding: getMarginOrPadding(left: 16),
          child: BagButton(
            merchItem: merchItem,
          ),
        ),
      ],
    );
  }
}
