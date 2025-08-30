import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';

class CloseButton extends StatelessWidget {
  const CloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49.w,
      width: 49.w,
      child: IconButton.filled(
        onPressed: () {
          final parentContext = context;
          showModalBottomSheet(
              context: parentContext,
              builder: (context) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    image: DecorationImage(
                        image: AssetImage(Paths.backgroundGradient1Path),
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Are you sure you want\nto stop the quest?',
                          style: TextStyle(
                            color: UiConstants.whiteColor,
                            fontSize: 20.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'By stopping the quest you lose nothing',
                          style: TextStyle(
                            color: UiConstants.whiteColor,
                            fontSize: 14.sp,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomButton(
                                  onTap: () => Navigator.pop(context, true),
                                  title: "Stop",
                                  buttonColor: Colors.transparent,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomButton(
                                  onTap: () => Navigator.pop(
                                    context,
                                  ),
                                  title: "Cancel",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).then((value) {
            if (value != null) {
              Navigator.pop(parentContext);
            }
          });
        },
        icon: const Icon(Icons.close),
        color: UiConstants.blackColor,
        splashColor: Colors.transparent,
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(UiConstants.whiteColor),
        ),
      ),
    );
  }
}
