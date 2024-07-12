import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobar_app/models/adPopUp.dart';
import 'package:url_launcher/url_launcher.dart';

class AdPopupManager {
  static const String openCountKey = 'app_open_count';

  Future<int> getOpenCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(openCountKey) ?? 0;
  }

  Future<void> incrementOpenCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentCount = await getOpenCount();
    await prefs.setInt(openCountKey, currentCount + 1);
  }

  Future<void> showAdPopupIfNeeded(BuildContext context, AdPopUp adPopUp) async {
    int openCount = await getOpenCount();
    if (openCount > 0 && adPopUp.isLive && openCount % 5 == 0) {
      showAdPopup(context, adPopUp);
    }
    await incrementOpenCount();
  }

  void showAdPopup(BuildContext context, AdPopUp adPopUp) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.all(10),
          title: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  adPopUp.adTitle,
                  style: TextStyle(fontSize: 24, fontFamily: 'Anton'),
                  textAlign: TextAlign.center,
                ),
              ),
              Positioned(
                right: -5.0,
                top: -5.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.close, color: Colors.black),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: adPopUp.adImage,
                  placeholder: (context, url) => Container(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(2)),
                    width: MediaQuery.of(context).size.width - 20,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  width: MediaQuery.of(context).size.width - 20,
                  fadeInDuration: const Duration(milliseconds: 200),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                adPopUp.adSubheader,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(adPopUp.adBody, style: TextStyle(fontSize: 12)),
            ],
          ),
          actions: [
            if (adPopUp.adButtonText.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  if (adPopUp.adUrl.isNotEmpty) {
                    String url = adPopUp.adUrl;
                    try {
                      if (Platform.isAndroid) {
                        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } else {
                        launchUrl(Uri.parse(url));
                      }
                    } catch (e) {
                      print("error: $e");
                    }
                  }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  adPopUp.adButtonText,
                  style: TextStyle(fontSize: 20, fontFamily: 'Anton', color: Theme.of(context).colorScheme.primary),
                ),
              ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }
}
