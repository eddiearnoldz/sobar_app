import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/utils/map_config.dart';

class MapProvider extends ChangeNotifier {
  GoogleMapController? _controller;
  CameraPosition _cameraPosition = const CameraPosition(
    target: londonCoordinates,
    zoom: 13,
  );
  bool _isBlackStyle = false;
  String _currentFilter = '';
  Drink? _selectedDrink;
  Pub? _selectedPub;
  bool _isBottomModalOpen = false;
  String? _selectedMarkerId;
  String? _previousSelectedMarkerId;

  GoogleMapController? get controller => _controller;
  CameraPosition get cameraPosition => _cameraPosition;
  bool get isBlackStyle => _isBlackStyle;
  String get currentFilter => _currentFilter;
  Drink? get selectedDrink => _selectedDrink;
  Pub? get selectedPub => _selectedPub;
  bool get isBottomModalOpen => _isBottomModalOpen;
  String? get selectedMarkerId => _selectedMarkerId;
  String? get previousSelectedMarkerId => _previousSelectedMarkerId;

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

  void setSelectedPub(Pub? pub) {
    _selectedPub = pub;
    notifyListeners();
  }

  void setBottomModalState(bool isOpen) {
    _isBottomModalOpen = isOpen;
    notifyListeners();
  }

  void setSelectedMarkerId(String? markerId) {
    _previousSelectedMarkerId = _selectedMarkerId;
    _selectedMarkerId = markerId;
    notifyListeners();
  }
}
