part of 'location_screen_cubit.dart';

abstract class LocationScreenState extends Equatable {
  const LocationScreenState();

  @override
  List<Object> get props => [];
}

class LocationScreenInitial extends LocationScreenState {}

class LocationScreenLoaded extends LocationScreenState {
  final LatLng coordinates;
  final String textLocation;

  const LocationScreenLoaded(
      {required this.coordinates, required this.textLocation});

  @override
  // TODO: implement props
  List<Object> get props => [coordinates, textLocation];
}
