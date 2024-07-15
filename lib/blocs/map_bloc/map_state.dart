part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoaded extends MapState {
  final GoogleMapController controller;
  final Set<Marker> markers;
  final bool isBlackStyle;
  final CameraPosition cameraPosition;

  const MapLoaded({
    required this.controller,
    this.markers = const {},
    this.isBlackStyle = false,
    required this.cameraPosition,
  });

  MapLoaded copyWith({
    GoogleMapController? controller,
    Set<Marker>? markers,
    bool? isBlackStyle,
    CameraPosition? cameraPosition,
  }) {
    return MapLoaded(
      controller: controller ?? this.controller,
      markers: markers ?? this.markers,
      isBlackStyle: isBlackStyle ?? this.isBlackStyle,
      cameraPosition: cameraPosition ?? this.cameraPosition,
    );
  }

  @override
  List<Object?> get props => [controller, markers, isBlackStyle, cameraPosition];
}
