import 'dart:developer';

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
    on<UpdateMarker>(_onUpdateMarker);
  }

  void _onInitializeMap(InitializeMap event, Emitter<MapState> emit) {
    _controller = event.controller;
    emit(MapLoaded(
      controller: _controller!,
      cameraPosition: mapProvider.cameraPosition,
      isBlackStyle: mapProvider.isBlackStyle,
      markers: const <Marker>{},
    ));
    log('Map initialized with controller: $_controller');
  }

  void _onToggleMapStyle(ToggleMapStyle event, Emitter<MapState> emit) async {
    if (state is MapLoaded) {
      final newStyle = !(state as MapLoaded).isBlackStyle;
      final newIconPath = newStyle ? 'assets/icons/coloured_pint_reversed.png' : 'assets/icons/coloured_pint.png';
      final newIcon = await BitmapDescriptor.asset(
        height: 30,
        const ImageConfiguration(),
        newIconPath,
      );

      mapProvider.updateMapStyle(newStyle);

      // Update markers with the new icon
      final updatedMarkers = (state as MapLoaded).markers.map((marker) {
        return marker.copyWith(iconParam: newIcon);
      }).toSet();

      emit((state as MapLoaded).copyWith(isBlackStyle: newStyle, markers: updatedMarkers));
      log('Map style toggled to: $newStyle');
    } else {
      log('ToggleMapStyle event received but state is not MapLoaded');
    }
  }

  void _onUpdateMarkers(UpdateMarkers event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      emit((state as MapLoaded).copyWith(markers: event.markers));
    } else {
      log('UpdateMarkers event received but state is not MapLoaded');
    }
  }

  void _onUpdateMarker(UpdateMarker event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      final updatedMarkers = (state as MapLoaded).markers.map((marker) {
        if (marker.markerId == event.marker.markerId) {
          return event.marker;
        }
        return marker;
      }).toSet();

      emit((state as MapLoaded).copyWith(markers: updatedMarkers));
      log('Marker updated: ${event.marker}');
    } else {
      log('UpdateMarker event received but state is not MapLoaded');
    }
  }

  void _onUpdateCameraPosition(UpdateCameraPosition event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      mapProvider.updateCameraPosition(event.cameraPosition);
      emit((state as MapLoaded).copyWith(cameraPosition: event.cameraPosition));
    } else {
      log('UpdateCameraPosition event received but state is not MapLoaded');
    }
  }
}
