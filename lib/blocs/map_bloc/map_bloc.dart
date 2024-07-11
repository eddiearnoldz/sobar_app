import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sobar_app/utils/map_provider.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapProvider mapProvider;
  GoogleMapController? _controller;

  MapBloc(this.mapProvider) : super(MapInitial()) {
    on<InitializeMap>(_onInitializeMap);
    on<ToggleMapStyle>(_onToggleMapStyle);
    on<UpdateMarkers>(_onUpdateMarkers);
    on<UpdateCameraPosition>(_onUpdateCameraPosition);
  }

  void _onInitializeMap(InitializeMap event, Emitter<MapState> emit) {
    _controller = event.controller;
    emit(MapLoaded(
      controller: _controller!,
      cameraPosition: mapProvider.cameraPosition,
      isBlackStyle: mapProvider.isBlackStyle,
      markers: const <Marker>{},
    ));
    print('Map initialized with controller: $_controller');
  }

void _onToggleMapStyle(ToggleMapStyle event, Emitter<MapState> emit) async {
  if (state is MapLoaded) {
    final newStyle = !(state as MapLoaded).isBlackStyle;
    final newIconPath = newStyle ? 'assets/icons/coloured_pint_reversed.png' : 'assets/icons/coloured_pint.png';
    final newIcon =  await BitmapDescriptor.asset(
      height: 20,
      const ImageConfiguration(),
      newIconPath,
    );

    mapProvider.updateMapStyle(newStyle);

    // Update markers with the new icon
    final updatedMarkers = (state as MapLoaded).markers.map((marker) {
      return marker.copyWith(iconParam: newIcon);
    }).toSet();

    emit((state as MapLoaded).copyWith(isBlackStyle: newStyle, markers: updatedMarkers));
    print('Map style toggled to: $newStyle');
  } else {
    print('ToggleMapStyle event received but state is not MapLoaded');
  }
}


  void _onUpdateMarkers(UpdateMarkers event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      emit((state as MapLoaded).copyWith(markers: event.markers));
      print('Markers updated: ${event.markers}');
    } else {
      print('UpdateMarkers event received but state is not MapLoaded');
    }
  }

  void _onUpdateCameraPosition(UpdateCameraPosition event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      mapProvider.updateCameraPosition(event.cameraPosition);
      emit((state as MapLoaded).copyWith(cameraPosition: event.cameraPosition));
      print('Camera position updated: ${event.cameraPosition}');
    } else {
      print('UpdateCameraPosition event received but state is not MapLoaded');
    }
  }
}
