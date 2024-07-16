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
  List<Drink> _drinkSearchResults = [];
  List<Pub> _pubSearchResults = [];

  GoogleMapController? get controller => _controller;
  CameraPosition get cameraPosition => _cameraPosition;
  bool get isBlackStyle => _isBlackStyle;
  List<String> get currentFilters => _currentFilters;
  Drink? get selectedDrink => _selectedDrink;
  Pub? get selectedPub => _selectedPub;
  bool get isBottomModalOpen => _isBottomModalOpen;
  String? get selectedMarkerId => _selectedMarkerId;
  String? get previousSelectedMarkerId => _previousSelectedMarkerId;
  List<Drink> get drinkSearchResults => _drinkSearchResults;
  List<Pub> get pubSearchResults => _pubSearchResults;

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
    if (markerId != _selectedMarkerId) {
      _previousSelectedMarkerId = _selectedMarkerId;
      _selectedMarkerId = markerId;
      notifyListeners();
    }
  }

  void setDrinkSearchResults(List<Drink> drinks) {
    _drinkSearchResults = drinks;
    notifyListeners();
  }

  void setPubSearchResults(List<Pub> pubs) {
    _pubSearchResults = pubs;
    notifyListeners();
  }

  void setPreviousSelectedMarkerId(String? markerId) {
    _previousSelectedMarkerId = markerId;
    notifyListeners();
  }
}
