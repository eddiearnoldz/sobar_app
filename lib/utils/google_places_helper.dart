import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesHelper {
  final String apiKey;

  GooglePlacesHelper(this.apiKey);

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    // Specify the fields you need
    const fields = 'formatted_phone_number,photos,opening_hours/weekday_text,website';
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
        '?input=${Uri.encodeComponent('$name $address')}'
        '&inputtype=textquery'
        '&fields=place_id'
        '&key=$apiKey';
    print('Requesting URL: $url'); // Debug log
    final response = await http.get(Uri.parse(url));
    print('Response Status Code: ${response.statusCode}'); // Debug log
    print('Response Body: ${response.body}'); // Debug log
    if (response.statusCode == 200) {
      final results = json.decode(response.body)['candidates'];
      if (results != null && results.isNotEmpty) {
        print('Found placeId: ${results[0]['place_id']} for $name, $address'); // Debug log
        return results[0]['place_id'];
      } else {
        print('No candidates found for $name, $address'); // Debug log
      }
    } else {
      print('Failed to fetch placeId for $name, $address: ${response.body}'); // Debug log
    }
    return null;
  }
}
