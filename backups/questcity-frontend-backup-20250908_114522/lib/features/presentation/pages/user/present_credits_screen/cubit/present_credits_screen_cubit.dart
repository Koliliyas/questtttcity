import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/present_credits_screen/cubit/present_credits_screen_state.dart';

class PresentCreditsScreenCubit extends Cubit<PresentCreditsScreenState> {
  PresentCreditsScreenCubit() : super(PresentCreditsScreenInitial());

  TextEditingController searchController = TextEditingController();

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}
