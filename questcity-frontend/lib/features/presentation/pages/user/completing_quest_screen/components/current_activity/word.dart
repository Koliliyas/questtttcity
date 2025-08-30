import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/cubit/completing_quest_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';

import 'utils.dart';

class Word extends StatelessWidget {
  final WordActivity activityModel;
  Word({super.key, required this.activityModel});

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            height: 10,
          ),
          Center(
            child: BlurryContainer(
                child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(80),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    Paths.artifactWordLockerIcon,
                    height: 150,
                    width: 150,
                  ),
                  CustomTextField(
                    controller: controller,
                    hintText: 'Enter the codeword',
                  ),
                ],
              ),
            )),
          ),
          CustomButton(
              title: activityModel.finalAction,
              onTap: () {
                if (controller.text.toLowerCase() == activityModel.correctAnswer.toLowerCase()) {
                  context.read<CompletingQuestScreenCubit>().completeActivity(
                      point: activityModel.pointNumber, id: activityModel.questId);
                }
              }),
        ],
      ),
    );
  }
}
