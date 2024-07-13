import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sobar_app/components/favourite_pub_pill.dart';
import 'package:sobar_app/components/launch_url_pill.dart';
import 'package:sobar_app/components/opening_hours_table.dart';
import 'package:sobar_app/components/pub_details_drinks_option_table.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/utils/google_places_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class PubDetailsSheet extends StatefulWidget {
  final Pub pub;
  final GooglePlacesHelper placesHelper;

  const PubDetailsSheet({super.key, required this.pub, required this.placesHelper});

  @override
  _PubDetailsSheetState createState() => _PubDetailsSheetState();
}

class _PubDetailsSheetState extends State<PubDetailsSheet> {
  late Future<Map<String, List<Drink>>> _drinkGroupsFuture;
  late Future<Map<String, dynamic>> _placesDetailsFuture;
  bool _showOpeningHours = false;

  @override
  void initState() {
    super.initState();
    _drinkGroupsFuture = _fetchDrinkGroups(widget.pub);
    _placesDetailsFuture = widget.placesHelper.getPlaceDetails(widget.pub.placeId ?? '');
  }

  Future<Map<String, List<Drink>>> _fetchDrinkGroups(Pub pub) async {
    List<Drink> drinks = await _getAllDrinks(pub);
    return _groupDrinksByType(drinks);
  }

  Future<List<Drink>> _getAllDrinks(Pub pub) async {
    List<Drink> drinks = [];

    for (var drinkRef in pub.drinks) {
      try {
        DocumentSnapshot snapshot = await drinkRef.get();
        if (snapshot.exists) {
          drinks.add(Drink.fromJson(drinkRef.id, snapshot.data() as Map<String, dynamic>));
        }
      } catch (e) {
        print('Error fetching drink: $e');
      }
    }

    return drinks;
  }

  Map<String, List<Drink>> _groupDrinksByType(List<Drink> drinks) {
    Map<String, List<Drink>> drinkGroups = {
      'draught': [],
      'can': [],
      'bottle': [],
      'wine': [],
      'spirit': [],
    };

    for (var drink in drinks) {
      drinkGroups[drink.type]?.add(drink);
    }

    return drinkGroups;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<Map<String, dynamic>>(
          future: _placesDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return const Center(child: Text('Error loading place details'));
            } else {
              final details = snapshot.data!;
              final phoneNumber = details['formatted_phone_number'];
              final photos = details['photos'] ?? [];
              final List<dynamic> openingHours = details['opening_hours']?['weekday_text'] ?? [];
              final website = details['website'];
              final rating = details['rating'];
              final ratingTotal = details['user_ratings_total'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 5,
                              child: Text(
                                widget.pub.locationName,
                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontFamily: 'Anton', fontSize: 24),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Text(
                                '${rating}★ (${ratingTotal})',
                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.pub.locationAddress,
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (photos.isNotEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.width / 3,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: photos.map<Widget>((photo) {
                            final photoUrl = 'https://maps.googleapis.com/maps/api/place/photo'
                                '?maxwidth=400&photoreference=${photo['photo_reference']}&key=${widget.placesHelper.apiKey}';
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: AspectRatio(
                                aspectRatio: 3 / 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: CachedNetworkImage(
                                    imageUrl: photoUrl,
                                    placeholder: (context, url) => Container(
                                      color: Theme.of(context).colorScheme.primary,
                                      height: MediaQuery.of(context).size.width / 3,
                                      width: MediaQuery.of(context).size.width / 2,
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                    fit: BoxFit.cover,
                                    height: MediaQuery.of(context).size.width / 3,
                                    width: MediaQuery.of(context).size.width / 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: _showOpeningHours ? null : Border.all(color: Theme.of(context).colorScheme.onPrimary),
                              borderRadius: BorderRadius.circular(5),
                              color: _showOpeningHours ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary),
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showOpeningHours = !_showOpeningHours;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: _showOpeningHours ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary,
                                  size: 15,
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  "hours",
                                  style: TextStyle(
                                    color: _showOpeningHours ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        LaunchUrlPill(
                          icon: Icons.phone,
                          label: "call",
                          onPressed: phoneNumber != null
                              ? () async {
                                  try {
                                    if (Platform.isAndroid) {
                                      launchUrl(Uri.parse(phoneNumber), mode: LaunchMode.externalApplication);
                                    } else {
                                      launchUrl(Uri.parse(phoneNumber));
                                    }
                                  } catch (e) {
                                    print("error: $e");
                                  }
                                }
                              : null,
                        ),
                        LaunchUrlPill(
                          icon: Icons.navigation,
                          label: "route",
                          onPressed: () async {
                            String url = 'https://www.google.com/maps/dir/?api=1&destination=${widget.pub.latitude},${widget.pub.longitude}';
                            try {
                              if (Platform.isAndroid) {
                                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                              } else {
                                launchUrl(Uri.parse(url));
                              }
                            } catch (e) {
                              print("error: $e");
                            }
                          },
                        ),
                        LaunchUrlPill(
                          icon: Icons.public,
                          label: "site",
                          onPressed: website != null
                              ? () {
                                  try {
                                    if (Platform.isAndroid) {
                                      launchUrl(Uri.parse(website), mode: LaunchMode.externalApplication);
                                    } else {
                                      launchUrl(Uri.parse(website));
                                    }
                                  } catch (e) {
                                    print("error: $e");
                                  }
                                }
                              : null,
                        ),
                        FavouritePubPill(pub: widget.pub),
                      ],
                    ),
                  ),
                  if (openingHours != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: OpeningHoursTable(
                        openingHours: openingHours,
                        showOpeningHours: _showOpeningHours,
                      ),
                    ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PubDetailsDrinksOptionTable(drinkGroupsFuture: _drinkGroupsFuture),
          ),
        ),
      ],
    );
  }
}
