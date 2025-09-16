import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/params/authentification_param.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/reset_password.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/new_password_screen/new_password_screen.dart';

part 'forget_password_screen_state.dart';

class ForgetPasswordScreenCubit extends Cubit<ForgetPasswordScreenState> {
  final ResetPassword resetPassword;
  ForgetPasswordScreenCubit({required this.resetPassword})
      : super(const ForgetPasswordScreenInitial());

  TextEditingController emailController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future reset(BuildContext context) async {
    final failureOrLoads =
        await resetPassword(AuthenticationParams(email: emailController.text));

    failureOrLoads.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_mapFailureToMessage(error)),
      )),
      (_) async {
        Navigator.push(
          context,
          FadeInRoute(
              NewPasswordScreen(
                email: emailController.text,
              ),
              Routes.newPasswordScreen),
        );
      },
    );
  }

  void onTextChanged() {
    ForgetPasswordScreenInitial currentState =
        state as ForgetPasswordScreenInitial;
    if (formKey.currentState!.validate()) {
      emit(currentState.copyWith(allFieldsValidate: true));
    } else {
      emit(currentState.copyWith(allFieldsValidate: false));
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    return super.close();
  }

  String _mapFailureToMessage(Failure error) {
    switch (error.runtimeType) {
      case ServerFailure _:
        return 'Server Failure';
      case InternetConnectionFailure _:
        return 'Internet Connection Failure';
      case EmailUncorrectedFailure _:
        return 'Email Address Uncorrected';
      default:
        return 'Unexpected Error';
    }
  }
}
