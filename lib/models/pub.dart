import 'package:cloud_firestore/cloud_firestore.dart';

class Pub {
  final String locationName;
  final String locationAddress;
  final String latitude;
  final String longitude;
  final String city;
  final List<DocumentReference> drinks;

  Pub({
    required this.locationName,
    required this.locationAddress,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.drinks,
  });

  factory Pub.fromJson(Map<String, dynamic> json) {
    return Pub(
      locationName: json['location_name'],
      locationAddress: json['location_address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      city: json['city'],
      drinks: (json['drinks'] as List<dynamic>).map((e) => e as DocumentReference).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_name': locationName,
      'location_address': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'drinks': drinks.map((e) => e.path).toList(),
    };
  }
}