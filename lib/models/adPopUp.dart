import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdPopUp {
  final String adBody;
  final String adButtonText;
  final String adImage;
  final String adSubheader;
  final String adTitle;
  final String adUrl;
  final bool isLive;

  AdPopUp({required this.adBody, required this.adButtonText, required this.adImage, required this.adSubheader, required this.adTitle, required this.adUrl, required this.isLive});

  factory AdPopUp.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AdPopUp(
      adBody: data['adBody'] ?? '',
      adButtonText: data['adButtonText'] ?? '',
      adImage: data['adImage'] ?? '',
      adSubheader: data['adSubheader'] ?? '',
      adTitle: data['adTitle'] ?? '',
      adUrl: data['adUrl'] ?? '',
      isLive: data['isLive'] ?? false,
    );
  }
}

class AdPopUpService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AdPopUp?> getAdPopUp() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('adPopUp').limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        return AdPopUp.fromFirestore(doc);
      }
    } catch (e) {
      log('Error loading ad popup: $e');
    }
    return null;
  }
}
