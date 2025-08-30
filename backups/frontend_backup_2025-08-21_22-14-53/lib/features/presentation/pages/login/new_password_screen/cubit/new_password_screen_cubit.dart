import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/params/authentification_param.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/verify_reset_password.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/login_screen/log_in_screen.dart';

part 'new_password_screen_state.dart';

class NewPasswordScreenCubit extends Cubit<NewPasswordScreenState> {
  final String email;
  final VerifyResetPassword verifyResetPassword;
  NewPasswordScreenCubit({required this.verifyResetPassword, required this.email})
      : super(const NewPasswordScreenInitial());

  TextEditingController codeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future verifyPassword(BuildContext context) async {
    final failureOrLoads = await verifyResetPassword(AuthenticationParams(
        email: email, password: passwordController.text, code: codeController.text));

    failureOrLoads.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_mapFailureToMessage(error)),
      )),
      (_) => Navigator.pushAndRemoveUntil(
          context, FadeInRoute(const LogInScreen(), Routes.logInScreen), (route) => false),
    );
  }

  void onTextChanged() {
    NewPasswordScreenInitial currentState = state as NewPasswordScreenInitial;
    if (formKey.currentState!.validate() &&
        passwordController.text.length == repeatPasswordController.text.length &&
        repeatPasswordController.text.length >= 8 &&
        passwordController.text.length >= 8 &&
        codeController.text.length == 6) {
      emit(currentState.copyWith(allFieldsValidate: true));
    } else {
      emit(currentState.copyWith(allFieldsValidate: false));
    }
  }

  @override
  Future<void> close() {
    codeController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    return super.close();
  }

  String _mapFailureToMessage(Failure error) {
    switch (error.runtimeType) {
      case ServerFailure _:
        return 'Server Failure';
      case InternetConnectionFailure _:
        return 'Internet Connection Failure';
      case EmailAlreadyExistsFailure _:
        return 'Email Already Exists';
      case EmailUncorrectedFailure _:
        return 'Email Address Uncorrected';
      default:
        return 'Unexpected Error';
    }
  }
}
