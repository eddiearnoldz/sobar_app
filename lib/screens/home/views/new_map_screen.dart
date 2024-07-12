import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sobar_app/blocs/pub_bloc/pub_bloc.dart';
import 'package:sobar_app/components/map_filter_bar.dart';
import 'package:sobar_app/components/filter_drink_text_field.dart';
import 'package:sobar_app/components/my_location_button.dart';
import 'package:sobar_app/components/selected_drink_filter_clear_button.dart';
import 'package:sobar_app/components/toggle_map_style_button.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobar_app/utils/google_places_helper.dart';
import 'package:sobar_app/utils/map_config.dart';
import 'package:sobar_app/blocs/map_bloc/map_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sobar_app/utils/map_provider.dart';

class NewMapScreen extends StatefulWidget {
  const NewMapScreen({super.key});

  @override
  _NewMapScreenState createState() => _NewMapScreenState();
}

class _NewMapScreenState extends State<NewMapScreen> {
  final LatLng _initialPosition = londonCoordinates;
  GooglePlacesHelper? _placesHelper;
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  String currentFilter = '';
  String searchText = '';
  List<Drink> filteredDrinks = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  GoogleMapController? _controller;
  final Location _location = Location();

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
      height: 20,
      const ImageConfiguration(),
      assetPath,
    );
    setState(() {
      customIcon = icon;
    });
  }

  void _showPubDetails(BuildContext context, Pub pub) {
    print('Showing details for pub: ${pub.id}');
  }

  void _filterMarkers(String filter) {
    if (filter == currentFilter) {
      filter = ''; // Reset filter if the same filter is clicked again
    }
    setState(() {
      currentFilter = filter;
    });
    context.read<PubBloc>().add(FilterPubs(filter: filter));
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
    context.read<PubBloc>().add(FilterPubs(filter: filter));
    Provider.of<MapProvider>(context, listen: false).setSelectedDrink(drink);
    _searchController.clear();
    setState(() {
      filteredDrinks = [];
    });
    unfocusTextField();
  }

  void _clearSelectedDrink() {
    Provider.of<MapProvider>(context, listen: false).setSelectedDrink(null);
    _filterMarkers('');
  }

  void unfocusTextField() {
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          BlocListener<PubBloc, PubState>(
            listener: (context, pubState) {
              if (pubState is PubLoaded || pubState is PubFiltered) {
                final pubs = pubState is PubLoaded ? pubState.pubs : (pubState as PubFiltered).filteredPubs;
                final markers = pubs.map((pub) {
                  return Marker(
                    markerId: MarkerId(pub.id),
                    position: LatLng(pub.latitude, pub.longitude),
                    icon: customIcon,
                    infoWindow: InfoWindow(
                      title: pub.locationName,
                      snippet: pub.locationAddress,
                      onTap: () => _showPubDetails(context, pub),
                    ),
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
                  myLocationButtonEnabled: false,
                  initialCameraPosition: mapState is MapLoaded
                      ? mapState.cameraPosition
                      : CameraPosition(
                          target: _initialPosition,
                          zoom: 12,
                        ),
                  mapType: MapType.normal,
                  markers: mapState is MapLoaded ? mapState.markers : <Marker>{},
                  onMapCreated: (controller) {
                    if (mapProvider.controller == null) {
                      mapProvider.setController(controller);
                      context.read<MapBloc>().add(InitializeMap(controller));
                      print('Map created and InitializeMap event added');
                    }
                  },
                  onCameraMove: (position) {
                    context.read<MapBloc>().add(UpdateCameraPosition(position));
                  },
                  style: mapState is MapLoaded && mapState.isBlackStyle ? mapStyleBlack : mapStyleSilver,
                );
              },
            ),
          ),
          const ToggleMapStyleButton(),
          Positioned(
            top: 100,
            left: 10,
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
            top: 50,
            left: 0,
            right: 0,
            child: MapFilterBar(
              currentFilter: mapProvider.currentFilter,
              onFilterChanged: (filter) {
                if (filter == mapProvider.currentFilter) {
                  filter = ''; // Reset filter if the same filter is clicked again
                }
                _clearSelectedDrink();
                mapProvider.setCurrentFilter(filter);
                context.read<PubBloc>().add(FilterPubs(filter: filter));
              },
            ),
          ),
          MyLocationButton(location: _location)
        ],
      ),
    );
  }
}
