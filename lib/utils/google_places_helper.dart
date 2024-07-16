import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class GooglePlacesHelper {
  final String apiKey;

  GooglePlacesHelper(this.apiKey);

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    // Specify the fields you need
    const fields = 'formatted_phone_number,photos,opening_hours/weekday_text,opening_hours/open_now,website,rating,user_ratings_total';
    final url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=$fields&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'OK') {
        return jsonResponse['result'] ?? {};
      } else {
        throw Exception('Failed to load place details: ${jsonResponse['status']}');
      }
    } else {
      throw Exception('Failed to load place details');
    }
  }

  Future<String?> getPlaceId(String name, String address) async {
    final String url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json'
        '?input=${Uri.encodeComponent('name,address')}'
        '&inputtype=textquery'
        '&fields=place_id'
        '&key=$apiKey';
    log('Requesting URL: $url'); 
    final response = await http.get(Uri.parse(url));
    log('Response Status Code: ${response.statusCode}'); 
    log('Response Body: ${response.body}'); 
    if (response.statusCode == 200) {
      final results = json.decode(response.body)['candidates'];
      if (results != null && results.isNotEmpty) {
        log('Found placeId: ${results[0]['place_id']} for $name, $address'); 
        return results[0]['place_id'];
      } else {
        log('No candidates found for  $name, $address'); 
      }
    } else {
      log('Failed to fetch placeId for  $name, $address: ${response.body}');
    }
    return null;
  }

  Future<Map<String, dynamic>> getPlaceDetailsForNewVenue(String placeId) async {
    const fields = 'name,formatted_address,geometry,place_id,vicinity';
    final url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=$fields&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'OK') {
        return jsonResponse['result'] ?? {};
      } else {
        throw Exception('Failed to load place details: ${jsonResponse['status']}');
      }
    } else {
      throw Exception('Failed to load place details');
    }
  }
}
