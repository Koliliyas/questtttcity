import 'package:flutter/material.dart';

class CustomTextErrorWidget extends StatelessWidget {
  const CustomTextErrorWidget({super.key, required this.textError});

  final String textError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        textError,
        style: const TextStyle(color: Colors.red, fontSize: 25),
      ),
    );
  }
}
