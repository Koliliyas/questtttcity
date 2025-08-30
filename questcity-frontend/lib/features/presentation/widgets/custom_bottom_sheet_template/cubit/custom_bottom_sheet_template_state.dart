part of 'custom_bottom_sheet_template_cubit.dart';

abstract class CustomBottomSheetTemplateState extends Equatable {
  const CustomBottomSheetTemplateState();

  @override
  List<Object> get props => [];
}

class CustomBottomSheetTemplateInitial extends CustomBottomSheetTemplateState {}

class CustomBottomSheetTemplateUpdating
    extends CustomBottomSheetTemplateState {}
