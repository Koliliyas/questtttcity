import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
part 'custom_bottom_sheet_template_state.dart';

class CustomBottomSheetTemplateCubit
    extends Cubit<CustomBottomSheetTemplateState> {
  CustomBottomSheetTemplateCubit() : super(CustomBottomSheetTemplateInitial());

  bool isVisibleKeyboard = false;
  double heightAllowance = 0;
  List<Key> widgetKeysList = [];

  keyboardVisibleChanged(bool isVisible) {
    isVisibleKeyboard = isVisible;
    emit(CustomBottomSheetTemplateUpdating());
    emit(CustomBottomSheetTemplateInitial());
  }

  addHeightToBottomSheet(bool isAdd, Key key, {double height = 24}) {
    if (widgetKeysList.contains(key) && isAdd) return;
    if (!widgetKeysList.contains(key) && !isAdd) return;

    if (isAdd) {
      widgetKeysList.add(key);
      heightAllowance += height;
    } else {
      widgetKeysList.remove(key);
      heightAllowance -= height;
    }
    emit(CustomBottomSheetTemplateUpdating());
    emit(CustomBottomSheetTemplateInitial());
  }

  reset() {
    isVisibleKeyboard = false;
    heightAllowance = 0;
    emit(CustomBottomSheetTemplateUpdating());
    emit(CustomBottomSheetTemplateInitial());
  }
}
