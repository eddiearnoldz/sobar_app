part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class InitializeMap extends MapEvent {
  final GoogleMapController controller;

  const InitializeMap(this.controller);

  @override
  List<Object> get props => [controller];
}

class ToggleMapStyle extends MapEvent {}

class UpdateMarkers extends MapEvent {
  final Set<Marker> markers;

  const UpdateMarkers(this.markers);

  @override
  List<Object> get props => [markers];
}

class UpdateMarker extends MapEvent {
  final Marker marker;

  const UpdateMarker(this.marker);

  @override
  List<Object> get props => [marker];
}

class UpdateCameraPosition extends MapEvent { // Add this event
  final CameraPosition cameraPosition;

  const UpdateCameraPosition(this.cameraPosition);

  @override
  List<Object> get props => [cameraPosition];
}
