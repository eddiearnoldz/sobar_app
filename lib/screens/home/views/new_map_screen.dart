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
import 'package:sobar_app/components/selected_drink_filter_clear_button.dart';
import 'package:sobar_app/components/toggle_map_style_button.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/screens/home/blocs/map_screen_controller.dart';
import 'package:sobar_app/utils/map_config.dart';
import 'package:sobar_app/utils/map_provider.dart';

class NewMapScreen extends StatefulWidget {
  const NewMapScreen({super.key});

  @override
  _NewMapScreenState createState() => _NewMapScreenState();
}

class _NewMapScreenState extends State<NewMapScreen> {
  final LatLng _initialPosition = londonCoordinates;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  Pub? _selectedPub;
  late MapScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MapScreenController(context);
    _controller.initializePlaces().then((_) async {
      await _controller.updateCustomIcon(context.read<MapBloc>().state is MapLoaded && (context.read<MapBloc>().state as MapLoaded).isBlackStyle);
      _controller.reinitializeMarkers();
    });
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
                    icon: isSelected ? _controller.selectedIcon : _controller.customIcon,
                    onTap: () {
                      mapProvider.setSelectedMarkerId(pub.id);
                      _controller.showCustomInfoWindow(pub);
                      _controller.updateMarker(pub.id);
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
                  _controller.updateCustomIcon(mapState.isBlackStyle);
                }
                return GoogleMap(
                  zoomControlsEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: mapState is MapLoaded
                      ? mapState.cameraPosition
                      : CameraPosition(
                          target: _initialPosition,
                          zoom: 12,
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
                    _controller.updateMarker(null);
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
                onTap: _controller.onCustomInfoWindowTap,
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
                    filteredDrinks: mapProvider.searchResults,
                    onSearchChanged: _controller.searchDrinks,
                    onDrinkSelected: _controller.filterPubsByDrink,
                    controller: _searchController,
                    focusNode: _focusNode,
                    isFocused: _isFocused,
                    unfocusTextField: _controller.unfocusTextField,
                  ),
                ),
                if (mapProvider.selectedDrink != null)
                  SelectedDrinkFilterClearButton(
                    selectedDrink: mapProvider.selectedDrink!,
                    onClear: _controller.clearSelectedDrink,
                  ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: MapFilterBar(
                    currentFilter: mapProvider.currentFilters.join(', '),
                    onFilterChanged: (filter) {
                      _controller.filterMarkers(filter);
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
