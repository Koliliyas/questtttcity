import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/params/register_param.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/domain/entities/person_entity.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/auth_register.dart';
import 'package:los_angeles_quest/features/presentation/pages/login/enter_the_code_screen/enter_the_code_screen.dart';

part 'sign_in_screen_state.dart';

class SignInScreenCubit extends Cubit<SignInScreenState> {
  final AuthRegister authRegister;
  SignInScreenCubit({required this.authRegister}) : super(const SignInScreenInitial());

  TextEditingController nicknameController = TextEditingController();
  TextEditingController fNameController = TextEditingController();
  TextEditingController sNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future register(BuildContext context) async {
    final failureOrLoads = await authRegister(RegisterParam(
        firstName: fNameController.text,
        nickname: nicknameController.text,
        lastName: sNameController.text,
        email: emailController.text,
        password: passwordController.text));

    return failureOrLoads.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_mapFailureToMessage(error)),
      )),
      (_) async {
        Navigator.push(
          context,
          FadeInRoute(
            const EnterTheCodeScreen(),
            Routes.enterTheCodeScreen,
            arguments: {
              'person': PersonEntity(
                id: '',
                firstName: fNameController.text,
                lastName: sNameController.text,
                email: emailController.text,
                password: passwordController.text,
                username: nicknameController.text,
                role: 0,
                isActive: true,
                isVerified: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )
            },
          ),
        );
      },
    );
  }

  void onTextChanged() {
    SignInScreenInitial currentState = state as SignInScreenInitial;
    if (formKey.currentState!.validate() &&
        passwordController.text == repeatPasswordController.text &&
        passwordController.text.length >= 8 &&
        repeatPasswordController.text.length >= 8) {
      emit(currentState.copyWith(allFieldsValidate: true));
    } else {
      emit(currentState.copyWith(allFieldsValidate: false));
    }
  }

  @override
  Future<void> close() {
    nicknameController.dispose();
    fNameController.dispose();
    sNameController.dispose();
    emailController.dispose();
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
