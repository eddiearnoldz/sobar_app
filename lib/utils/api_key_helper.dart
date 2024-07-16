import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeApiKeys() async {
  try {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) {
      await auth.signInAnonymously();
    }

    // Fetch iOS API key
    HttpsCallable callableIos = FirebaseFunctions.instance.httpsCallable('getGoogleMapsApiKeyIos');
    final resultsIos = await callableIos();
    final googleMapsApiKeyIos = resultsIos.data['apiKey'];

    // Fetch Android API key
    HttpsCallable callableAndroid = FirebaseFunctions.instance.httpsCallable('getGoogleMapsApiKeyAndroid');
    final resultsAndroid = await callableAndroid();
    final googleMapsApiKeyAndroid = resultsAndroid.data['apiKey'];

    // Store API keys in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('google_maps_api_key_ios', googleMapsApiKeyIos);
    await prefs.setString('google_maps_api_key_android', googleMapsApiKeyAndroid);

    log('Stored iOS API key: $googleMapsApiKeyIos');
    log('Stored Android API key: $googleMapsApiKeyAndroid');
  } catch (e) {
    log('Error: $e');
  }
}
