import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobar_app/models/adPopUp.dart';
import 'package:sobar_app/utils/globals.dart';
import 'package:url_launcher/url_launcher.dart';

class AdPopupManager {

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
      Future.delayed(const Duration(seconds: 8), () => showAdPopup(context, adPopUp));
    }
    await incrementOpenCount();
  }

  void showAdPopup(BuildContext context, AdPopUp adPopUp) {
    showDialog(
      context: context,
      builder: (context) {
        return Stack(children: [
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Set border radius here
            ),
            backgroundColor: HexColor('#F8F48F'),
            insetPadding: const EdgeInsets.all(16),
            contentPadding: const EdgeInsets.all(16),
            title: Align(
              alignment: Alignment.center,
              child: Text(
                adPopUp.adTitle,
                style: const TextStyle(fontSize: 24, fontFamily: 'Anton'),
                textAlign: TextAlign.center,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: adPopUp.adImage,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(color: HexColor('#F8F48F'), borderRadius: BorderRadius.circular(2)),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width - 32,
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width - 32,
                    fadeInDuration: const Duration(milliseconds: 200),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  adPopUp.adSubheader,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(adPopUp.adBody, style: const TextStyle(fontSize: 12, height: 1.2)),
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
                        log("error: $e");
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
                    style: TextStyle(fontSize: 20, fontFamily: 'Anton', color: HexColor('#F8F48F')),
                  ),
                ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          ),
          Positioned(
            top: 15,
            right: 5,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(color: HexColor('#F8F48F'), shape: BoxShape.circle, border: Border.all(width: 1, color: Theme.of(context).colorScheme.onPrimary)),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }
}
