import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sobar_app/blocs/pub_bloc/pub_bloc.dart';
import 'package:sobar_app/components/map_filter_bar.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobar_app/utils/google_places_helper.dart';
import 'package:sobar_app/utils/map_styles.dart';
import 'package:sobar_app/utils/widget_to_map_icon.dart';
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

  void _filterMarkers(String filter) {
    if (filter == currentFilter) {
      filter = ''; // Reset filter if the same filter is clicked again
    }
    setState(() {
      currentFilter = filter;
    });
    context.read<PubBloc>().add(FilterPubs(filter: filter));
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
            top: 60,
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
}
