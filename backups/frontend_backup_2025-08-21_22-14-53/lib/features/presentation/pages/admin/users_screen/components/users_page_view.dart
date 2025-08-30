import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';

class UsersPageView extends StatelessWidget {
  final PageController controller;
  final Function(int index) onPageChanged;
  final List<Widget> children;

  const UsersPageView(
      {super.key,
      required this.controller,
      required this.onPageChanged,
      required this.children});

  @override
  Widget build(BuildContext context) {
    return ExpandablePageView.builder(
        controller: controller,
        itemBuilder: (context, index) => FractionallySizedBox(
              widthFactor: 1 / controller.viewportFraction,
              child: children[index],
            ),
        itemCount: children.length,
        onPageChanged: onPageChanged);
  }
}
