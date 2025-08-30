import 'package:equatable/equatable.dart';

class CustomTextFieldState extends Equatable {
  final bool isValid;
  final bool isNotEmpty;
  final String? errorText;

  const CustomTextFieldState(
      {required this.isValid, required this.isNotEmpty, this.errorText});

  @override
  List<Object?> get props => [isValid, errorText];
}
