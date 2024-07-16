import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sobar_app/utils/map_provider.dart';

class MyLocationButton extends StatefulWidget {
  const MyLocationButton({super.key, required this.location});

  final Location location;

  @override
  _MyLocationButtonState createState() => _MyLocationButtonState();
}

class _MyLocationButtonState extends State<MyLocationButton> {
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await widget.location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await widget.location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await widget.location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await widget.location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    return Positioned(
      top: 90,
      right: 10,
      child: FloatingActionButton(
        heroTag: 'myLocationButton',
        backgroundColor: Colors.white,
        mini: true,
        onPressed: () async {
          try {
            var locationData = await widget.location.getLocation();
            print(locationData);
            if (mapProvider.controller != null) {
              mapProvider.controller?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(locationData.latitude!, locationData.longitude!),
                  15,
                ),
              );
            } else {
              print("Map controller is not yet initialized");
            }
          } catch (e) {
            log("Error getting location: $e");
          }
        },
        child: Icon(
          Icons.location_pin,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
