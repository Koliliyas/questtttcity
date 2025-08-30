import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/cubit/completing_quest_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';

import 'current_activity.dart';

class CombinationLocker extends StatefulWidget {
  final CombinationLockerActivity activityModel;
  const CombinationLocker({super.key, required this.activityModel});

  @override
  State<CombinationLocker> createState() => _CombinationLockerState();
}

class _CombinationLockerState extends State<CombinationLocker> {
  List<int> values = [0, 0, 0, 0];
  String imageUrl = Paths.artifactCombinationLockerIconI;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(children: [
            Align(
                alignment: Alignment.center,
                // bottom: 200,
                // right: -10,
                child: Image.asset(
                  imageUrl,
                  // width: 450,
                  fit: BoxFit.fitWidth,
                )),
            Align(
              // alignment: Alignment(0, 0.4),
              // bottom: 230,
              // right: 70,
              child: SizedBox(
                width: 280,
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (rowIndex) => Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          gradient: const LinearGradient(
                              colors: [Colors.black, Colors.white, Colors.white, Colors.black],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0, 0.45, 0.55, 1]),
                        ),
                        width: 50,
                        height: 100,
                        child: FlutterCarousel.builder(
                            itemCount: 10,
                            options: FlutterCarouselOptions(
                              initialPage: 10,
                              viewportFraction: 0.37,
                              scrollDirection: Axis.vertical,
                              enableInfiniteScroll: true,
                              showIndicator: false,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.4,
                              onPageChanged: (index, _) {
                                values[rowIndex] = index;
                              },
                            ),
                            itemBuilder: (context, index, realIndex) {
                              return SizedBox(
                                height: 100,
                                child: Text(index.toString(),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold)),
                              );
                            }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: CustomButton(
            title: widget.activityModel.finalAction,
            onTap: () {
              if (values.join() == widget.activityModel.correctAnswer) {
                setState(() {
                  imageUrl = Paths.artifactCombinationLockerIconIOpen;
                });
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    context.read<CompletingQuestScreenCubit>().completeActivity(
                        point: widget.activityModel.pointNumber, id: widget.activityModel.questId);
                  }
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
