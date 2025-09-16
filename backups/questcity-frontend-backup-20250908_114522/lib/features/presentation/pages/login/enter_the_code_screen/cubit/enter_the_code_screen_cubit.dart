import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/params/authentification_param.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/auth_login.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/verify_code.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth/verify_reset_password.dart';
import 'package:los_angeles_quest/features/domain/usecases/person/get_me.dart';
import 'package:los_angeles_quest/features/domain/usecases/person/update_me.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/home_screen.dart';

part 'enter_the_code_screen_state.dart';

class EnterTheCodeScreenCubit extends Cubit<EnterTheCodeScreenState> {
  final String email;
  final String password;
  final bool? needUpdateData;
  final AuthLogin authLogin;
  final VerifyCode verifyCode;
  final VerifyResetPassword verifyResetPassword;
  final GetMe getMe;
  final UpdateMe updateMe;
  final FirebaseMessaging firebaseMessaging;

  EnterTheCodeScreenCubit(
      {required this.email,
      required this.password,
      this.needUpdateData,
      required this.authLogin,
      required this.verifyCode,
      required this.verifyResetPassword,
      required this.getMe,
      required this.updateMe,
      required this.firebaseMessaging})
      : super(const EnterTheCodeScreenInitial());

  TextEditingController codeController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future codeVerify(BuildContext context) async {
    final failureOrLoads = await verifyCode(AuthenticationParams(
        email: email, password: password, code: codeController.text));

    failureOrLoads.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_mapFailureToMessage(error)),
      )),
      (_) async => await _login(context),
    );
  }

  Future _login(BuildContext context) async {
    final failureOrLoads = await authLogin(
      AuthenticationParams(
          email: email,
          password: password,
          fbid: await firebaseMessaging.getToken()),
    );

    return failureOrLoads.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mapFailureToMessage(error)),
          ),
        );
      },
      (_) async => await _getMeData(context),
    );
  }

  // Future _updateMe(BuildContext context) async {
  //   final failureOrLoads = await updateMe(
  //     PersonEntity(
  //         firstName: person!.firstName,
  //         lastName: person!.lastName,
  //         email: person!.email,
  //         username: person!.username),
  //   );

  //   return failureOrLoads.fold(
  //     (error) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(_mapFailureToMessage(error)),
  //         ),
  //       );
  //     },
  //     (_) async => await _getMeData(context),
  //   );
  // }

  Future _getMeData(BuildContext context) async {
    final failureOrLoads = await getMe(NoParams());

    return failureOrLoads.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mapFailureToMessage(error)),
          ),
        );
      },
      (person) {
        Navigator.push(
          context,
          FadeInRoute(
            const HomeScreen(),
            Routes.homeScreen,
            arguments: {
              'role': Utils.convertServerRoleToEnumItem(person.role)
            },
          ),
        );
      },
    );
  }

  void onTextChanged() {
    EnterTheCodeScreenInitial currentState = state as EnterTheCodeScreenInitial;
    if (formKey.currentState!.validate() && codeController.text.length == 6) {
      emit(currentState.copyWith(allFieldsValidate: true));
    } else {
      emit(currentState.copyWith(allFieldsValidate: false));
    }
  }

  @override
  Future<void> close() {
    codeController.dispose();
    return super.close();
  }

  String _mapFailureToMessage(Failure error) {
    switch (error.runtimeType) {
      case ServerFailure _:
        return 'Server Failure';
      case InternetConnectionFailure _:
        return 'Internet Connection Failure';
      case UncorrectedVerifyCodeFailure _:
        return '	Code Of Verify Uncorrect';
      case PasswordUncorrectedFailure _:
        return 'Password Uncorrected';
      case UserNotFoundFailure _:
        return 'User Not Found';
      case UserNotVerifyFailure _:
        return 'User Not Verify';
      default:
        return 'Unexpected Error';
    }
  }
}
