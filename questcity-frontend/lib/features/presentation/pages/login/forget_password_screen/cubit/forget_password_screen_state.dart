part of 'forget_password_screen_cubit.dart';

abstract class ForgetPasswordScreenState extends Equatable {
  const ForgetPasswordScreenState();

  @override
  List<Object> get props => [];
}

class ForgetPasswordScreenInitial extends ForgetPasswordScreenState {
  final bool allFieldsValidate;

  const ForgetPasswordScreenInitial({this.allFieldsValidate = false});

  ForgetPasswordScreenInitial copyWith({bool? allFieldsValidate}) {
    return ForgetPasswordScreenInitial(
        allFieldsValidate: allFieldsValidate ?? this.allFieldsValidate);
  }

  @override
  List<Object> get props => [allFieldsValidate];
}
