import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sobar_app/models/drink.dart';

class Pub {
  String id;
  final String locationName;
  final String locationAddress;
  final String latitude;
  final String longitude;
  final String city;
  final List<DocumentReference> drinks;
  final String? placeId;
  List<Drink> drinksData;

  // Flags for drink types
  bool hasDraught = false;
  bool hasBottle = false;
  bool hasCan = false;
  bool hasWine = false;
  bool hasSpirit = false;

  Pub({
    this.id = "",
    required this.locationName,
    required this.locationAddress,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.drinks,
    this.placeId,
    this.drinksData = const [], // Initialize drinksData
  });

  factory Pub.fromJson(String id, Map<String, dynamic> json) {
    return Pub(
      id: id,
      locationName: json['location_name'] ?? '',
      locationAddress: json['location_address'] ?? '',
      latitude: json['latitude'].toString(),
      longitude: json['longitude'].toString(),
      city: json['city'] ?? '',
      drinks: (json['drinks'] as List<dynamic>?)?.map((e) => e as DocumentReference).toList() ?? [],
      placeId: json['place_id'] as String?,
    );
  }

  double get parsedLatitude => _parseDouble(latitude);
  double get parsedLongitude => _parseDouble(longitude);

  static double _parseDouble(String value) {
    return double.tryParse(value) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'location_name': locationName,
      'location_address': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'drinks': drinks.map((e) => e.path).toList(),
      'place_id': placeId,
    };
  }
}
