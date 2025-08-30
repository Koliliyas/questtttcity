import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';

class AccountPageView extends StatelessWidget {
  final PageController controller;
  final Function(int index) onPageChanged;
  final List<Widget> children;

  const AccountPageView(
      {super.key,
      required this.controller,
      required this.onPageChanged,
      required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpandablePageView.builder(
            controller: controller,
            itemBuilder: (context, index) => Padding(
                  padding: getMarginOrPadding(bottom: 12),
                  child: FractionallySizedBox(
                    widthFactor: 1 / controller.viewportFraction,
                    child: children[index],
                  ),
                ),
            itemCount: children.length,
            onPageChanged: onPageChanged),
      ],
    );
  }
}
