import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/components/account_chip.dart';

class ProfileChipsView extends StatelessWidget {
  const ProfileChipsView(
      {super.key,
      required this.onTapChip,
      required this.activeChipIndex,
      required this.chipNames});

  final int activeChipIndex;
  final Function(int chipIndex) onTapChip;
  final List<String> chipNames;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 10.w,
      spacing: 10.w,
      children: List.generate(
        chipNames.length,
        (index) => AccountChip(
          onTap: onTapChip,
          index: index,
          isSelected: activeChipIndex == index,
          title: chipNames[index],
        ),
      ),
    );
  }
}
