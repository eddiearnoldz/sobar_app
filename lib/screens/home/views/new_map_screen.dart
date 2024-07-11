import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sobar_app/blocs/pub_bloc/pub_bloc.dart';
import 'package:sobar_app/components/map_filter_bar.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobar_app/utils/google_places_helper.dart';
import 'package:sobar_app/utils/map_styles.dart';
import 'package:sobar_app/blocs/map_bloc/map_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sobar_app/utils/map_provider.dart';

class NewMapScreen extends StatefulWidget {
  @override
  _NewMapScreenState createState() => _NewMapScreenState();
}

class _NewMapScreenState extends State<NewMapScreen> {
  final LatLng _initialPosition = const LatLng(51.5074, -0.1278); // London coordinates
  GooglePlacesHelper? _placesHelper;
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  String currentFilter = '';
  String searchText = '';
  List<Drink> filteredDrinks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePlaces();
    _loadCustomIcon().then((icon) {
      setState(() {
        customIcon = icon;
      });
    });
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

  Future<BitmapDescriptor> _loadCustomIcon() async {
    return await BitmapDescriptor.asset(
      const ImageConfiguration(),
      'assets/icons/coloured_pint.png',
    );
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
      final drinks = pubs.expand((pub) => pub.drinksData).toList();
      setState(() {
        filteredDrinks = drinks.where((drink) => drink.name.toLowerCase().startsWith(text.toLowerCase())).toList();
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
  }

  void _clearSelectedDrink() {
    Provider.of<MapProvider>(context, listen: false).setSelectedDrink(null);
    _filterMarkers('');
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<PubBloc, PubState>(
            builder: (context, pubState) {
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
              return BlocBuilder<MapBloc, MapState>(
                builder: (context, mapState) {
                  return GoogleMap(
                    zoomControlsEnabled: true,
                    initialCameraPosition: mapState is MapLoaded
                        ? mapState.cameraPosition
                        : CameraPosition(
                            target: _initialPosition,
                            zoom: 11,
                          ),
                    mapType: MapType.normal,
                    markers: mapState is MapLoaded ? mapState.markers : Set<Marker>(),
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
              );
            },
          ),
          Positioned(
            bottom: 70,
            right: 10,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                context.read<MapBloc>().add(ToggleMapStyle());
              },
              mini: true,
              child: BlocBuilder<MapBloc, MapState>(
                builder: (context, state) {
                  if (state is MapLoaded) {
                    return Icon(
                      state.isBlackStyle ? Icons.brightness_3 : Icons.brightness_5,
                      size: 20,
                    );
                  } else {
                    return Icon(Icons.brightness_3, size: 20);
                  }
                },
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 10,
            right: 10,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Search for a drink...',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onChanged: _searchDrinks,
                  ),
                ),
                if (filteredDrinks.isNotEmpty)
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredDrinks.length,
                      itemBuilder: (context, index) {
                        final drink = filteredDrinks[index];
                        return GestureDetector(
                          onTap: () => _filterPubsByDrink(drink),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: _getDrinkColor(drink.type),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Image.network(drink.imageUrl, width: 40, height: 40, fit: BoxFit.contain),
                                SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(drink.name, style: TextStyle(color: Colors.white)),
                                    Text(drink.abv, style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (mapProvider.selectedDrink != null)
            Positioned(
              top: 150,
              right: 10,
              child: GestureDetector(
                onTap: _clearSelectedDrink,
                child: Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(mapProvider.selectedDrink!.imageUrl),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 10),
                      ),
                    ),
                  ],
                ),
              ),
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
                mapProvider.setCurrentFilter(filter);
                context.read<PubBloc>().add(FilterPubs(filter: filter));
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getDrinkColor(String type) {
    switch (type) {
      case 'draught':
        return Colors.purple.withOpacity(0.8);
      case 'bottle':
        return Colors.red.withOpacity(0.8);
      case 'can':
        return Colors.blue.withOpacity(0.8);
      case 'wine':
        return Colors.green.withOpacity(0.8);
      case 'spirit':
        return Colors.yellow.withOpacity(0.8);
      default:
        return Theme.of(context).colorScheme.primary.withOpacity(0.8);
    }
  }
}
