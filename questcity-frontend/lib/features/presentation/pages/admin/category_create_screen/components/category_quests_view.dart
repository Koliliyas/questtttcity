import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

class CategoryQuestsView extends StatelessWidget {
  const CategoryQuestsView(
      {super.key, required this.onTap, required this.selectedIndexes});

  final Function(int index) onTap;
  final List<int> selectedIndexes;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18.w,
        mainAxisSpacing: 18.w,
        childAspectRatio: 170.h / 235.h, // Adjust this ratio as needed
      ),
      itemCount: 6,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: getMarginOrPadding(bottom: 12, left: 9, right: 9),
          height: 235.h, // Fixed height for each item
          decoration: BoxDecoration(
            color: UiConstants.whiteColor.withValues(alpha: .2),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            children: [
              Expanded(
                child: GradientCard(
                  contentPadding: EdgeInsets.zero,
                  contentMargin: getMarginOrPadding(top: 10),
                  body: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: Image.asset(
                          index % 2 == 0 ? Paths.quest1Path : Paths.quest2Path,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8.w,
                        right: 12.w,
                        left: 12.w,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: getMarginOrPadding(
                                    left: 5, right: 9, top: 2, bottom: 2),
                                decoration: BoxDecoration(
                                  color:
                                      UiConstants.whiteColor.withValues(alpha: .32),
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.star_rate_rounded,
                                        color: UiConstants.yellowColor,
                                        size: 25.w),
                                    SizedBox(width: 2.w),
                                    Padding(
                                      padding: getMarginOrPadding(top: 4),
                                      child: Text(
                                        '5',
                                        style: UiConstants.textStyle4.copyWith(
                                            color: UiConstants.whiteColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selectedIndexes.contains(index))
                                Container(
                                  width: 24.w,
                                  height: 24.w,
                                  decoration: const BoxDecoration(
                                      color: UiConstants.greenColor,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.check,
                                      color: UiConstants.whiteColor),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  borderRadius: 24.r,
                ),
              ),
              SizedBox(height: 13.h),
              Text(
                'Hollywood Hills',
                style: UiConstants.textStyle4
                    .copyWith(color: UiConstants.whiteColor),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
