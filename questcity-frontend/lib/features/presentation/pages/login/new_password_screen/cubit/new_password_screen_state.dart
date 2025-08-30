part of 'new_password_screen_cubit.dart';

abstract class NewPasswordScreenState extends Equatable {
  const NewPasswordScreenState();

  @override
  List<Object> get props => [];
}

class NewPasswordScreenInitial extends NewPasswordScreenState {
  final bool allFieldsValidate;

  const NewPasswordScreenInitial({this.allFieldsValidate = false});

  NewPasswordScreenInitial copyWith({bool? allFieldsValidate}) {
    return NewPasswordScreenInitial(
        allFieldsValidate: allFieldsValidate ?? this.allFieldsValidate);
  }

  @override
  List<Object> get props => [allFieldsValidate];
}
