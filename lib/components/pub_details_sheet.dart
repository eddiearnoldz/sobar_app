import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sobar_app/components/favourite_pub_button.dart';
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
  int _selectedPage = 0;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.pub.locationName,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontFamily: 'Anton', fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            widget.pub.locationAddress,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, dynamic>>(
            future: _placesDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading place details'));
              } else {
                final details = snapshot.data!;
                final phoneNumber = details['formatted_phone_number'];
                final photos = details['photos'] ?? [];
                final openingHours = details['opening_hours']?['weekday_text'] ?? [];
                final website = details['website'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (photos.isEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.width / 3,
                        width: MediaQuery.of(context).size.width,
                      ),
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
                    Row(
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
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                          child: GestureDetector(
                            onTap: () async {
                              if (phoneNumber != null) {
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
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: 15,
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  "call",
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                          child: GestureDetector(
                            onTap: () async {
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
                            child: Row(
                              children: [
                                Icon(
                                  Icons.navigation,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: 15,
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  "route",
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                          child: GestureDetector(
                            onTap: () {
                              if (website != null) {
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
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.public,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: 15,
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  "site",
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        FavouriteButton(pub: widget.pub),
                      ],
                    ),
                    if (openingHours != null)
                      AnimatedOpacity(
                        opacity: _showOpeningHours ? 1 : 0,
                        duration: Duration(milliseconds: 500),
                        child: Visibility(
                          visible: _showOpeningHours,
                          maintainState: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Opening Hours: ",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: openingHours.sublist(0, (openingHours.length / 2).ceil()).map<Widget>((day) {
                                      return Text(
                                        day,
                                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10),
                                      );
                                    }).toList(),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: openingHours.sublist((openingHours.length / 2).ceil()).map<Widget>((day) {
                                      return Text(
                                        day,
                                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['draught', 'can', 'bottle', 'wine', 'spirit'].map((type) {
              int index = ['draught', 'can', 'bottle', 'wine', 'spirit'].indexOf(type);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPage = index;
                  });
                },
                child: Stack(
                  children: [
                    Text('${type}s',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Anton',
                          color: Theme.of(context).colorScheme.onPrimary,
                        )),
                    if (_selectedPage == index)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 2,
                          width: 40,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<Map<String, List<Drink>>>(
              future: _drinkGroupsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading drinks'));
                } else {
                  final drinkGroups = snapshot.data!;
                  final drinksOfType = drinkGroups.values.elementAt(_selectedPage);

                  return AnimatedOpacity(
                    opacity: 1,
                    duration: Duration(milliseconds: 500),
                    child: Visibility(
                      visible: true,
                      maintainState: true,
                      child: drinksOfType.isEmpty
                          ? Center(child: Text('No ${drinkGroups.keys.elementAt(_selectedPage)}s at this pub yet'))
                          : ListView.builder(
                              itemCount: drinksOfType.length,
                              itemBuilder: (context, index) {
                                final drink = drinksOfType[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: CachedNetworkImage(
                                          imageUrl: drink.imageUrl,
                                          placeholder: (context, url) => Container(
                                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                                            width: 40,
                                            height: 40,
                                          ),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                          height: 40,
                                          width: 40,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            drink.name,
                                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                          ),
                                          Text(
                                            'abv: ${drink.abv}',
                                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
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
}
