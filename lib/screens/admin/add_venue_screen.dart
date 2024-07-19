import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/utils/globals.dart';
import 'package:sobar_app/utils/google_places_helper.dart';

class AddVenueScreen extends StatefulWidget {
  const AddVenueScreen({super.key});

  @override
  _AddVenueScreenState createState() => _AddVenueScreenState();
}

class _AddVenueScreenState extends State<AddVenueScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  late GooglePlacesHelper _placesHelper;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _initializePlacesHelper();
  }

  Future<void> _initializePlacesHelper() async {
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
  }

  Future<void> _searchPlace() async {
    if (_placesHelper == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key is not available')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults.clear();
      _selectedPlace = null;
    });

    final placeIds = await _placesHelper.getPlaceId(_nameController.text, _addressController.text);
    if (placeIds != null && placeIds.isNotEmpty) {
      List<Map<String, dynamic>> results = [];
      for (String placeId in placeIds) {
        final placeDetails = await _placesHelper.getPlaceDetailsForNewVenue(placeId);
        if (placeDetails != null) {
          results.add(placeDetails);
        }
      }
      setState(() {
        _searchResults = results;
        log(_searchResults.toString());
        _isSearching = false;
      });
    } else {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _addVenue() async {
    if (_selectedPlace == null) return;

    try {
      final placeId = _selectedPlace!['place_id'];
      final existingVenue = await FirebaseFirestore.instance.collection('pubs').where('place_id', isEqualTo: placeId).get();

      if (existingVenue.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'venue already exists in the database',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          )),
        );
        FocusScope.of(context).unfocus();
        _clearForm();
        return;
      }

      final vicinity = _selectedPlace!['vicinity'];
      final city = vicinity?.split(', ').last ?? "London";

      final newPub = Pub(
        id: '',
        locationName: _selectedPlace!['name'],
        locationAddress: _selectedPlace!['formatted_address'],
        latitude: _selectedPlace!['geometry']['location']['lat'].toString(),
        longitude: _selectedPlace!['geometry']['location']['lng'].toString(),
        city: city,
        drinks: [],
        placeId: placeId,
      );

      await FirebaseFirestore.instance.collection('pubs').add(newPub.toJson());

      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Venue added: ${newPub.locationName}',
          style: const TextStyle(color: wineColour),
          textAlign: TextAlign.center,
        )),
      );

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add venue: ${e.toString()}',
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _addressController.clear();
      _nameController.clear();
      _searchResults.clear();
      _selectedPlace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('add venue'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'name',
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                cursorColor: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'address',
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                cursorColor: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSearching ? null : _searchPlace,
                child: _isSearching
                    ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
                    : Text(
                        'search venue',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                      ),
              ),
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'search results:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ListTile(
                        title: Text(result['name']),
                        subtitle: Text(result['formatted_address']),
                        onTap: () {
                          setState(() {
                            _selectedPlace = result;
                            _searchResults.clear();
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (_selectedPlace != null) ...[
                Text(
                  'selected Pub: ${_selectedPlace!['name']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _addVenue,
                      child: Text(
                        'add venue',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _clearForm,
                      child: Text(
                        'clear',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
