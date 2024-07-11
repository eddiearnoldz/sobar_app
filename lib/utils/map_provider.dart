import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapProvider extends ChangeNotifier {
  GoogleMapController? _controller;
  CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(51.5074, -0.1278),
    zoom: 11,
  );
  bool _isBlackStyle = false;

  GoogleMapController? get controller => _controller;
  CameraPosition get cameraPosition => _cameraPosition;
  bool get isBlackStyle => _isBlackStyle;

  void setController(GoogleMapController controller) {
    _controller = controller;
    notifyListeners();
  }

  void updateCameraPosition(CameraPosition cameraPosition) {
    _cameraPosition = cameraPosition;
    notifyListeners();
  }

  void updateMapStyle(bool isBlackStyle) {
    _isBlackStyle = isBlackStyle;
    notifyListeners();
  }
}