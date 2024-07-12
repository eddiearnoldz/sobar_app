import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sobar_app/utils/map_provider.dart';

class MyLocationButton extends StatelessWidget {
  const MyLocationButton({super.key, required this.location});

  final Location location;

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    return Positioned(
      top: 190,
      right: 10,
      child: FloatingActionButton(
        heroTag: 'myLocationButton',
        backgroundColor: Colors.white,
        mini: true,
        onPressed: () async {
          print("running my location");
          var locationData = await location.getLocation();
          print(locationData);
          if (mapProvider.controller != null) {
            mapProvider.controller?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(locationData.latitude!, locationData.longitude!), 15));
          } else {
            print("Map controller is not yet initialized");
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
