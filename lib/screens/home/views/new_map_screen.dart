import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sobar_app/blocs/map_bloc/map_bloc.dart';
import 'package:sobar_app/blocs/pub_bloc/pub_bloc.dart';
import 'package:sobar_app/components/custom_info_window.dart';
import 'package:sobar_app/components/favourite_pubs_filter_button.dart';
import 'package:sobar_app/components/filter_drink_text_field.dart';
import 'package:sobar_app/components/map_filter_bar.dart';
import 'package:sobar_app/components/pub_details_sheet.dart';
import 'package:sobar_app/components/selected_drink_filter_clear_button.dart';
import 'package:sobar_app/components/toggle_map_style_button.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/utils/google_places_helper.dart';
import 'package:sobar_app/utils/map_config.dart';
import 'package:sobar_app/utils/map_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewMapScreen extends StatefulWidget {
  const NewMapScreen({super.key});

  @override
  _NewMapScreenState createState() => _NewMapScreenState();
}

class _NewMapScreenState extends State<NewMapScreen> {
  final LatLng _initialPosition = londonCoordinates;
  GooglePlacesHelper? _placesHelper;
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor selectedIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  String searchText = '';
  List<Drink> filteredDrinks = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  GoogleMapController? _controller;
  final Location _location = Location();
  Pub? _selectedPub;
  bool _isBottomModalOpen = false;

  @override
  void initState() {
    super.initState();
    _initializePlaces();
    _updateCustomIcon(context.read<MapBloc>().state is MapLoaded && (context.read<MapBloc>().state as MapLoaded).isBlackStyle);
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    _applyFilters();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initializePlaces() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? apiKey;
      if (Platform.isIOS) {
        apiKey = prefs.getString('google_maps_api_key_ios');
      } else if (Platform.isAndroid) {
        apiKey = prefs.getString('google_maps_api_key_android');
      }
      if (apiKey != null) {
        _placesHelper = GooglePlacesHelper(apiKey);
        print('GooglePlacesHelper initialized with API key: $apiKey');
      } else {
        print('API key is still null after fetching.');
      }
    } catch (e) {
      print('Error during _initializePlaces: $e');
    }
  }

  Future<void> _updateCustomIcon(bool isBlackStyle) async {
    final assetPath = isBlackStyle ? 'assets/icons/coloured_pint_reversed.png' : 'assets/icons/coloured_pint.png';
    final icon = await BitmapDescriptor.asset(
      height: 30,
      const ImageConfiguration(),
      assetPath,
    );
    setState(() {
      customIcon = icon;
    });

    const selectedAssetPath = "assets/icons/icon_selected_pint.png";
    final selectedIcon = await BitmapDescriptor.asset(
      height: 30,
      const ImageConfiguration(),
      selectedAssetPath,
    );
    setState(() {
      this.selectedIcon = selectedIcon;
    });
  }

  void _applyFilters() {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    context.read<PubBloc>().add(FilterPubs(filters: mapProvider.currentFilters));
  }

  void _filterMarkers(String filter) {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    setState(() {
      if (mapProvider.currentFilters.contains(filter)) {
        mapProvider.removeFilter(filter);
      } else {
        mapProvider.addFilter(filter);
      }
    });
    _applyFilters();
  }

  void _searchDrinks(String text) {
    setState(() {
      searchText = text;
    });

    if (text.isEmpty) {
      setState(() {
        filteredDrinks = [];
      });
      return;
    }

    final pubState = context.read<PubBloc>().state;
    if (pubState is PubLoaded || pubState is PubFiltered) {
      final pubs = pubState is PubLoaded ? pubState.pubs : (pubState as PubFiltered).filteredPubs;
      final Set<String> uniqueDrinkIds = {};
      final List<Drink> uniqueDrinks = [];

      for (var pub in pubs) {
        for (var drink in pub.drinksData) {
          if (drink.name.toLowerCase().contains(text.toLowerCase()) && !uniqueDrinkIds.contains(drink.id)) {
            uniqueDrinkIds.add(drink.id);
            uniqueDrinks.add(drink);
          }
        }
      }

      setState(() {
        filteredDrinks = uniqueDrinks;
      });
    }
  }

  void _filterPubsByDrink(Drink drink) {
    final filter = 'drink_${drink.id}';
    context.read<PubBloc>().add(FilterPubs(filters: [filter]));
    Provider.of<MapProvider>(context, listen: false).setSelectedDrink(drink);
    _searchController.clear();
    setState(() {
      filteredDrinks = [];
    });
    unfocusTextField();
  }

  void _clearSelectedDrink() {
    Provider.of<MapProvider>(context, listen: false).setSelectedDrink(null);
    _applyFilters();
  }

  void unfocusTextField() {
    _focusNode.unfocus();
  }

  void showPubDetailsSheet(BuildContext context, Pub pub, GooglePlacesHelper placesHelper) {
    final screenHeight = MediaQuery.of(context).size.height;

    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    mapProvider.setBottomModalState(true);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SizedBox(
          height: screenHeight * 0.75,
          child: PubDetailsSheet(pub: pub, placesHelper: placesHelper),
        );
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      isScrollControlled: true, // To allow the modal to be full screen if needed
    ).whenComplete(() {
      mapProvider.setBottomModalState(false);
    });
  }

  void _showCustomInfoWindow(Pub pub) {
    if (mounted) {
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      mapProvider.setSelectedPub(pub);
    } else {
      _selectedPub = pub;
    }
  }

  void _onCustomInfoWindowTap() {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    if (mapProvider.selectedPub != null) {
      showPubDetailsSheet(context, mapProvider.selectedPub!, _placesHelper!);
    }
  }

  void _updateMarker(String? markerId) {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final mapState = context.read<MapBloc>().state;
    if (mapState is MapLoaded) {
      final markers = mapState.markers;
      final previousMarkerId = mapProvider.previousSelectedMarkerId;

      if (previousMarkerId != null) {
        final previousMarker = markers.firstWhere(
          (marker) => marker.markerId.value == previousMarkerId,
          orElse: () => Marker(markerId: MarkerId('')),
        );
        final updatedPreviousMarker = previousMarker.copyWith(iconParam: customIcon);
        context.read<MapBloc>().add(UpdateMarker(updatedPreviousMarker));
      }

      if (markerId != null) {
        final marker = markers.firstWhere(
          (marker) => marker.markerId.value == markerId,
          orElse: () => Marker(markerId: MarkerId('')),
        );
        final updatedMarker = marker.copyWith(iconParam: selectedIcon);
        context.read<MapBloc>().add(UpdateMarker(updatedMarker));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          BlocListener<PubBloc, PubState>(
            listener: (context, pubState) {
              if (pubState is PubLoaded || pubState is PubFiltered) {
                final pubs = pubState is PubLoaded ? pubState.pubs : (pubState as PubFiltered).filteredPubs;
                final markers = pubs.map((pub) {
                  final isSelected = pub.id == mapProvider.selectedMarkerId;
                  return Marker(
                    markerId: MarkerId(pub.id),
                    position: LatLng(pub.parsedLatitude, pub.parsedLongitude),
                    icon: isSelected ? selectedIcon : customIcon,
                    onTap: () {
                      mapProvider.setSelectedMarkerId(pub.id);
                      _showCustomInfoWindow(pub);
                      _updateMarker(pub.id);
                    },
                  );
                }).toSet();

                context.read<MapBloc>().add(UpdateMarkers(markers));
                print('Markers updated in PubLoaded or PubFiltered state');
              }
            },
            child: BlocBuilder<MapBloc, MapState>(
              builder: (context, mapState) {
                if (mapState is MapLoaded) {
                  _updateCustomIcon(mapState.isBlackStyle);
                }
                return GoogleMap(
                  zoomControlsEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: mapState is MapLoaded
                      ? mapState.cameraPosition
                      : CameraPosition(
                          target: _initialPosition,
                          zoom: 9,
                        ),
                  mapType: MapType.normal,
                  markers: mapState is MapLoaded ? mapState.markers : <Marker>{},
                  onMapCreated: (controller) {
                    if (mapProvider.controller == null || mapState is MapInitial) {
                      mapProvider.setController(controller);
                      context.read<MapBloc>().add(InitializeMap(controller));
                      print('Map created and InitializeMap event added');
                    }
                  },
                  onTap: (_) {
                    if (mapProvider.isBottomModalOpen) {
                      Navigator.of(context).pop();
                      mapProvider.setBottomModalState(false);
                    }
                    mapProvider.setSelectedPub(null);
                    mapProvider.setSelectedMarkerId(null);
                    _updateMarker(null);
                    setState(() {});
                    FocusScope.of(context).unfocus();
                  },
                  onCameraMove: (position) {
                    context.read<MapBloc>().add(UpdateCameraPosition(position));
                  },
                  style: mapState is MapLoaded && mapState.isBlackStyle ? mapStyleBlack : mapStyleSilver,
                );
              },
            ),
          ),
          if (mapProvider.selectedPub != null || _selectedPub != null)
            Positioned(
              bottom: 5,
              left: 5,
              right: 5,
              child: GestureDetector(
                onTap: _onCustomInfoWindowTap,
                child: CustomInfoWindow(pub: mapProvider.selectedPub != null ? mapProvider.selectedPub! : _selectedPub!),
              ),
            ),
          SafeArea(
            child: Stack(
              children: [
                const ToggleMapStyleButton(),
                Positioned(
                  top: 50,
                  left: 0,
                  right: 10,
                  child: FilterDrinkTextField(
                    filteredDrinks: filteredDrinks,
                    onSearchChanged: _searchDrinks,
                    onDrinkSelected: _filterPubsByDrink,
                    controller: _searchController,
                    focusNode: _focusNode,
                    isFocused: _isFocused,
                    unfocusTextField: unfocusTextField,
                  ),
                ),
                if (mapProvider.selectedDrink != null)
                  SelectedDrinkFilterClearButton(
                    selectedDrink: mapProvider.selectedDrink!,
                    onClear: _clearSelectedDrink,
                  ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: MapFilterBar(
                    currentFilter: mapProvider.currentFilters.join(', '),
                    onFilterChanged: (filter) {
                      _filterMarkers(filter);
                    },
                  ),
                ),
                const FavouritePubsFilterButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
