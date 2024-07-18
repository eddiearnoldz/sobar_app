import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sobar_app/models/usefulLink.dart';
import 'package:sobar_app/utils/globals.dart';
import 'package:url_launcher/url_launcher.dart';

class UsefulLinksScreen extends StatelessWidget {
  const UsefulLinksScreen({super.key});

  Future<List<UsefulLink>> _fetchUsefulLinks() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('usefulLinks').get();
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    final links = List<Map<String, dynamic>>.from(data['link_cards'] ?? []);
    return links.map((linkData) => UsefulLink.fromJson(linkData)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> coloursList = [bottleColour, canColour, spiritColour, wineColour, draughtColour];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: const Text(
          'useful links',
          style: TextStyle(
            fontFamily: 'Anton',
            letterSpacing: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<UsefulLink>>(
        future: _fetchUsefulLinks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('error loading links'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('no links available'));
          } else {
            final links = snapshot.data!;
            return ListView.builder(
              itemCount: links.length,
              itemBuilder: (context, index) {
                final link = links[index];
                final colour = coloursList[index];
                return Column(
                  children: [
                    ListTile(
                      tileColor: Theme.of(context).colorScheme.primary,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            link.title.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Anton',
                              letterSpacing: 1,
                            ),
                          ),
                          Icon(
                            Icons.link,
                            color: colour,
                            size: 40,
                          ),
                        ],
                      ),
                      subtitle: Text(link.paragraph),
                      onTap: () async {
                        try {
                          if (Platform.isAndroid) {
                            launchUrl(Uri.parse(link.urlLink), mode: LaunchMode.externalApplication);
                          } else {
                            launchUrl(Uri.parse(link.urlLink));
                          }
                        } catch (e) {
                          log("error: $e");
                        }
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    )
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
