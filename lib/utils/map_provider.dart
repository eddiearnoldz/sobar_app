import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/utils/map_config.dart';

class MapProvider extends ChangeNotifier {
  GoogleMapController? _controller;
  CameraPosition _cameraPosition = const CameraPosition(
    target: londonCoordinates,
    zoom: 11,
  );
  bool _isBlackStyle = false;
  String _currentFilter = '';
  Drink? _selectedDrink;

  GoogleMapController? get controller => _controller;
  CameraPosition get cameraPosition => _cameraPosition;
  bool get isBlackStyle => _isBlackStyle;
  String get currentFilter => _currentFilter;
  Drink? get selectedDrink => _selectedDrink;

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

  void setCurrentFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSelectedDrink(Drink? drink) {
    _selectedDrink = drink;
    notifyListeners();
  }
}
