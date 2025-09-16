import 'package:los_angeles_quest/utils/logger.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/completing_quest_screen/cubit/completing_quest_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'current_activity.dart';

class QrCode extends StatefulWidget {
  final QrCodeActivity activityModel;
  const QrCode({super.key, required this.activityModel});

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> with WidgetsBindingObserver {
  final controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  StreamSubscription<Object?>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen((event) {
      appLogger.d(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(widget.activityModel.name),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: MobileScanner(
              controller: controller,
            ),
          ),
        ),
        CustomButton(
            title: widget.activityModel.finalAction,
            onTap: () {
              context.read<CompletingQuestScreenCubit>().completeActivity(
                  point: widget.activityModel.pointNumber, id: widget.activityModel.questId);
            }),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    controller.dispose();
  }
}
