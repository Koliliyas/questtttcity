import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/cubit/completing_quest_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'current_activity.dart';

class Photo extends StatefulWidget {
  final PhotoActivity activityModel;
  const Photo({super.key, required this.activityModel});

  @override
  State<Photo> createState() => _PhotoState();
}

class _PhotoState extends State<Photo> {
  final ImagePicker _picker = ImagePicker();
  final ScreenshotController screenshotController = ScreenshotController();
  Uint8List? _image;
  @override
  void didChangeDependencies() {
    _picker.pickImage(source: ImageSource.camera).then((value) async {
      final data = await value!.readAsBytes();
      setState(() {
        _image = data;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(widget.activityModel.name),
          const SizedBox(height: 20),
          _image != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Screenshot(
                    controller: screenshotController,
                    child: Stack(alignment: Alignment.bottomCenter, children: [
                      Image.memory(_image!),
                      // Positioned(
                      //   bottom: 0,
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(32.0),
                      //     child: BlurryContainer(
                      //         child: Container(
                      //       decoration: BoxDecoration(
                      //         color: Colors.white.withAlpha(80),
                      //         borderRadius: BorderRadius.circular(16),
                      //       ),
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(24.0),
                      //         child: Column(
                      //           children: [
                      //             Text('#Questicity'),
                      //             Text("I've completed stage four of the quest"),
                      //           ],
                      //         ),
                      //       ),
                      //     )),
                      //   ),
                      // )
                    ]),
                  ),
                )
              : const SizedBox.shrink(),
          CustomButton(
              title: widget.activityModel.finalAction,
              onTap: () async {
                // final data = await screenshotController.capture();
                final currentContext = context;

                final file = XFile.fromData(_image!, mimeType: 'image/png');
                await Share.shareXFiles([file], text: "I've completed stage four of the quest");
                if (!mounted) return;
                currentContext.read<CompletingQuestScreenCubit>().completeActivity(
                    point: widget.activityModel.pointNumber, id: widget.activityModel.questId);
              }),
        ],
      ),
    );
  }
}
