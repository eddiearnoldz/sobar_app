import 'package:cloud_firestore/cloud_firestore.dart';

class Pub {
  final String id;
  final String locationName;
  final String locationAddress;
  final double latitude;
  final double longitude;
  final String city;
  final List<DocumentReference> drinks;
  final String? placeId;

  Pub({
    required this.id,
    required this.locationName,
    required this.locationAddress,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.drinks,
    this.placeId,
  });

  factory Pub.fromJson(String id, Map<String, dynamic> json) {
    return Pub(
      id: id,
      locationName: json['location_name'] ?? '',
      locationAddress: json['location_address'] ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      city: json['city'] ?? '',
      drinks: (json['drinks'] as List<dynamic>?)?.map((e) => e as DocumentReference).toList() ?? [],
      placeId: json['place_id'] as String?,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
