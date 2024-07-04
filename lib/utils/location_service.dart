import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  Future<bool> requestPermission() async {
    final permission = await location.requestPermission();
    return permission == PermissionStatus.granted;
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      if (await location.serviceEnabled() || await location.requestService()) {
        if (await requestPermission()) {
          return await location.getLocation();
        }
      }
      print("Stopping here");
    } catch (e) {
      print(e);
    }
  }
}
