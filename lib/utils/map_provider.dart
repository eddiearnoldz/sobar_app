import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/utils/map_config.dart';

class MapProvider extends ChangeNotifier {
  GoogleMapController? _controller;
  CameraPosition _cameraPosition = const CameraPosition(
    target: londonCoordinates,
    zoom: 12,
  );
  bool _isBlackStyle = false;
  List<String> _currentFilters = [];
  Drink? _selectedDrink;
  Pub? _selectedPub;
  bool _isBottomModalOpen = false;
  String? _selectedMarkerId;
  String? _previousSelectedMarkerId;
  List<Drink> _searchResults = [];

  GoogleMapController? get controller => _controller;
  CameraPosition get cameraPosition => _cameraPosition;
  bool get isBlackStyle => _isBlackStyle;
  List<String> get currentFilters => _currentFilters;
  Drink? get selectedDrink => _selectedDrink;
  Pub? get selectedPub => _selectedPub;
  bool get isBottomModalOpen => _isBottomModalOpen;
  String? get selectedMarkerId => _selectedMarkerId;
  String? get previousSelectedMarkerId => _previousSelectedMarkerId;
  List<Drink> get searchResults => _searchResults;

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

  void addFilter(String filter) {
    if (!_currentFilters.contains(filter)) {
      _currentFilters.add(filter);
      notifyListeners();
    }
  }

  void removeFilter(String filter) {
    if (_currentFilters.contains(filter)) {
      _currentFilters.remove(filter);
      notifyListeners();
    }
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

  void setSearchResults(List<Drink> drinks) {
    _searchResults = drinks;
    notifyListeners();
  }
}
