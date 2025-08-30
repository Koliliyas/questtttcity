import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/cubit/completing_quest_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';

import 'current_activity.dart';

class FileActivityScreen extends StatefulWidget {
  final FileActivity activityModel;
  const FileActivityScreen({super.key, required this.activityModel});

  @override
  State<FileActivityScreen> createState() => _FileActivityScreenState();
}

class _FileActivityScreenState extends State<FileActivityScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.activityModel.name),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ActualBlurryContainer(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        )
                      else
                        Image.asset(
                          Paths.downloadIcon,
                          width: 100,
                          height: 100,
                        ),
                      CustomButton(
                          title: widget.activityModel.finalAction,
                          onTap: () async {
                            final currentContext = context;
                            setState(() {
                              isLoading = true;
                            });
                            for (final file in widget.activityModel.files.entries) {
                              await currentContext
                                  .read<CompletingQuestScreenCubit>()
                                  .saveFile(file.value, file.key);
                            }
                            setState(() {
                              isLoading = false;
                            });
                            if (!mounted) return;
                            currentContext.read<CompletingQuestScreenCubit>().completeActivity(
                                point: widget.activityModel.pointNumber,
                                id: widget.activityModel.questId);
                          }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ActualBlurryContainer extends StatelessWidget {
  const ActualBlurryContainer({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return BlurryContainer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(80),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
