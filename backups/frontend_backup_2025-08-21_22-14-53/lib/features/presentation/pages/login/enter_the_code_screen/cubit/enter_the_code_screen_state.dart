part of 'enter_the_code_screen_cubit.dart';

abstract class EnterTheCodeScreenState extends Equatable {
  const EnterTheCodeScreenState();

  @override
  List<Object> get props => [];
}

class EnterTheCodeScreenInitial extends EnterTheCodeScreenState {
  final bool allFieldsValidate;

  const EnterTheCodeScreenInitial({this.allFieldsValidate = false});

  EnterTheCodeScreenInitial copyWith({bool? allFieldsValidate}) {
    return EnterTheCodeScreenInitial(
        allFieldsValidate: allFieldsValidate ?? this.allFieldsValidate);
  }

  @override
  List<Object> get props => [allFieldsValidate];
}

class EnterTheCodeScreenLoading extends EnterTheCodeScreenState {
  final String? message;

  const EnterTheCodeScreenLoading({this.message});

  @override
  List<Object> get props => [message ?? ''];
}
