import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/quest_screen_controller.dart';

class BagButton extends StatelessWidget {
  final List<MerchItem> merchItem;
  const BagButton({super.key, required this.merchItem});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: () => QuestScreenController.orderInventorySheet(context, merchItem),
      icon: SvgPicture.asset(Paths.bag),
      color: UiConstants.redColor,
      padding: getMarginOrPadding(all: 19),
      splashColor: Colors.transparent,
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(UiConstants.purpleColor),
      ),
    );
  }
}
