import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  GoogleMapController? _controller;

  MapBloc() : super(MapInitial()) {
    on<InitializeMap>(_onInitializeMap);
    on<ToggleMapStyle>(_onToggleMapStyle);
    on<UpdateMarkers>(_onUpdateMarkers);
    on<UpdateCameraPosition>(_onUpdateCameraPosition);
  }

  void _onInitializeMap(InitializeMap event, Emitter<MapState> emit) {
    _controller = event.controller;
    emit(MapLoaded(
      controller: _controller!,
      cameraPosition: const CameraPosition(
        target: LatLng(51.5074, -0.1278),
        zoom: 11,
      ),
    ));
    print('Map initialized with controller: $_controller');
  }

  void _onToggleMapStyle(ToggleMapStyle event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      emit((state as MapLoaded).copyWith(isBlackStyle: !(state as MapLoaded).isBlackStyle));
    } else {
      print('ToggleMapStyle event received but state is not MapLoaded');
    }
  }

  void _onUpdateMarkers(UpdateMarkers event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      emit((state as MapLoaded).copyWith(markers: event.markers));
    } else {
      print('UpdateMarkers event received but state is not MapLoaded');
    }
  }

  void _onUpdateCameraPosition(UpdateCameraPosition event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      emit((state as MapLoaded).copyWith(cameraPosition: event.cameraPosition));
    } else {
      print('UpdateCameraPosition event received but state is not MapLoaded');
    }
  }
}
