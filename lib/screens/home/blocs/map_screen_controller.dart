import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sobar_app/blocs/map_bloc/map_bloc.dart';
import 'package:sobar_app/blocs/pub_bloc/pub_bloc.dart';
import 'package:sobar_app/components/pub_details_sheet.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/utils/google_places_helper.dart';
import 'package:sobar_app/utils/map_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreenController {
  final BuildContext context;

  MapScreenController(this.context);

  GooglePlacesHelper? _placesHelper;
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor selectedIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

  Future<void> initializePlaces() async {
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
        log('GooglePlacesHelper initialized with API key: $apiKey');
      } else {
        log('API key is still null after fetching.');
      }
    } catch (e) {
      log('Error during _initializePlaces: $e');
    }
  }

  Future<void> updateCustomIcon(bool isBlackStyle) async {
    final assetPath = isBlackStyle ? 'assets/icons/coloured_pint_reversed.png' : 'assets/icons/coloured_pint.png';
    final icon = await BitmapDescriptor.asset(
      height: 30,
      const ImageConfiguration(),
      assetPath,
    );

    customIcon = icon;

    const selectedAssetPath = "assets/icons/icon_selected_pint.png";
    final selectedIcon = await BitmapDescriptor.asset(
      height: 30,
      const ImageConfiguration(),
      selectedAssetPath,
    );

    this.selectedIcon = selectedIcon;
  }

  void applyFilters() {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    context.read<PubBloc>().add(FilterPubs(filters: mapProvider.currentFilters));
    reinitializeMarkers();
  }

  void filterMarkers(String filter) {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    if (mapProvider.currentFilters.contains(filter)) {
      mapProvider.removeFilter(filter);
    } else {
      mapProvider.addFilter(filter);
    }
    applyFilters();
  }

  void filterPubsByDrink(Drink drink) {
    final filter = 'drink_${drink.id}';
    context.read<PubBloc>().add(FilterPubs(filters: [filter]));
    Provider.of<MapProvider>(context, listen: false).setSelectedDrink(drink);
    Provider.of<MapProvider>(context, listen: false).setDrinkSearchResults([]);
  }

  void clearSelectedDrink(TextEditingController drinkSearchController) {
    Provider.of<MapProvider>(context, listen: false).setSelectedDrink(null);
    drinkSearchController.clear();
    applyFilters();
    unfocusTextField();
  }

  void onPubSelected(Pub pub, TextEditingController pubSearchController) {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    mapProvider.setSelectedPub(pub);
    mapProvider.setSelectedMarkerId(pub.id); // Ensure selected marker ID is set
    updateMarker(pub.id);
    showCustomInfoWindow(pub);
    unfocusTextField();
    pubSearchController.clear();
    mapProvider.setPubSearchResults([]);

    // Center the camera on the selected pub's coordinates
    mapProvider.controller?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(pub.parsedLatitude, pub.parsedLongitude), 15),
    );
  }

  void unfocusTextField() {
    FocusScope.of(context).unfocus();
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

  void showCustomInfoWindow(Pub pub) {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    mapProvider.setSelectedPub(pub);
  }

  void onCustomInfoWindowTap() {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    if (mapProvider.selectedPub != null) {
      showPubDetailsSheet(context, mapProvider.selectedPub!, _placesHelper!);
    }
  }

  void updateMarker(String? markerId) {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final mapState = context.read<MapBloc>().state;

    if (mapState is MapLoaded) {
      final markers = mapState.markers;
      final previousMarkerId = mapProvider.previousSelectedMarkerId;

      // If there is a previous marker and it's not the same as the new marker, update it to customIcon
      if (previousMarkerId != null && previousMarkerId != markerId) {
        final previousMarker = markers.firstWhere(
          (marker) => marker.markerId.value == previousMarkerId,
          orElse: () => const Marker(markerId: MarkerId('')),
        );
        final updatedPreviousMarker = previousMarker.copyWith(iconParam: customIcon);
        context.read<MapBloc>().add(UpdateMarker(updatedPreviousMarker));
      }

      // If there is a new marker, update it to selectedIcon
      if (markerId != null) {
        final marker = markers.firstWhere(
          (marker) => marker.markerId.value == markerId,
          orElse: () => const Marker(markerId: MarkerId('')),
        );
        final updatedMarker = marker.copyWith(iconParam: selectedIcon);
        context.read<MapBloc>().add(UpdateMarker(updatedMarker));

        // Set the new marker as both selected and previous marker
        mapProvider.setSelectedMarkerId(markerId);
        mapProvider.setPreviousSelectedMarkerId(markerId);
      } else {
        // If markerId is null, reset the previous marker as well
        mapProvider.setSelectedMarkerId(previousMarkerId);
        mapProvider.setPreviousSelectedMarkerId(previousMarkerId);
      }
    }
  }

  void reinitializeMarkers() {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final pubState = context.read<PubBloc>().state;
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
            showCustomInfoWindow(pub);
            updateMarker(pub.id);
          },
        );
      }).toSet();

      context.read<MapBloc>().add(UpdateMarkers(markers));
    }
  }

  void searchPubs(String text) {
    final pubState = context.read<PubBloc>().state;
    List<Pub> filteredPubs = [];

    if (pubState is PubLoaded || pubState is PubFiltered) {
      final pubs = pubState is PubLoaded ? pubState.pubs : (pubState as PubFiltered).filteredPubs;
      filteredPubs = pubs.where((pub) => pub.locationName.toLowerCase().contains(text.toLowerCase())).toList();
    }

    Provider.of<MapProvider>(context, listen: false).setPubSearchResults(filteredPubs);
  }

  void searchDrinks(String text) {
    final pubState = context.read<PubBloc>().state;
    List<Drink> uniqueDrinks = [];
    Set<String> uniqueDrinkIdentifiers = {};

    if (pubState is PubLoaded || pubState is PubFiltered) {
      final pubs = pubState is PubLoaded ? pubState.pubs : (pubState as PubFiltered).filteredPubs;
      for (var pub in pubs) {
        for (var drink in pub.drinksData) {
          final drinkIdentifier = '${drink.id}_${drink.type}';
          if (drink.name.toLowerCase().contains(text.toLowerCase()) && !uniqueDrinkIdentifiers.contains(drinkIdentifier)) {
            uniqueDrinkIdentifiers.add(drinkIdentifier);
            uniqueDrinks.add(drink);
          }
        }
      }
    }

    Provider.of<MapProvider>(context, listen: false).setDrinkSearchResults(uniqueDrinks);
  }
}
