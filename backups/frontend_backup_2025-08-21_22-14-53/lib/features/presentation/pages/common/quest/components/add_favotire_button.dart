import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class AddToFavoriteButton extends StatelessWidget {
  const AddToFavoriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: () {},
      icon: const Icon(Icons.favorite),
      color: UiConstants.redColor,
      padding: getMarginOrPadding(all: 19),
      splashColor: Colors.transparent,
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(UiConstants.purpleColor),
      ),
    );
  }
}
