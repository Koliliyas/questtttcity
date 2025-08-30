import 'package:equatable/equatable.dart';

abstract class PresentCreditsScreenState extends Equatable {
  const PresentCreditsScreenState();

  @override
  List<Object?> get props => [];
}

class PresentCreditsScreenInitial extends PresentCreditsScreenState {}

class PresentCreditsScreenUpdating extends PresentCreditsScreenState {}

class PresentCreditsScreenSearchTextChanged extends PresentCreditsScreenState {
  final String searchText;

  const PresentCreditsScreenSearchTextChanged(this.searchText);

  @override
  List<Object?> get props => [searchText];
}
