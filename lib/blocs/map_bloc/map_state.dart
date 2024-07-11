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
  final CameraPosition cameraPosition; // Add this line

  const MapLoaded({
    required this.controller,
    this.markers = const {},
    this.isBlackStyle = false,
    required this.cameraPosition, // Add this line
  });

  MapLoaded copyWith({
    GoogleMapController? controller,
    Set<Marker>? markers,
    bool? isBlackStyle,
    CameraPosition? cameraPosition, // Add this line
  }) {
    return MapLoaded(
      controller: controller ?? this.controller,
      markers: markers ?? this.markers,
      isBlackStyle: isBlackStyle ?? this.isBlackStyle,
      cameraPosition: cameraPosition ?? this.cameraPosition, // Add this line
    );
  }

  @override
  List<Object?> get props => [controller, markers, isBlackStyle, cameraPosition]; // Add this line
}
