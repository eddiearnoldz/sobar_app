import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/components/review_tile.dart';
import 'package:sobar_app/utils/globals.dart';
import 'package:url_launcher/url_launcher.dart';

class DrinkScreen extends StatefulWidget {
  final Drink drink;
  final Function(Drink) onSearchOnMap;

  const DrinkScreen({super.key, required this.drink, required this.onSearchOnMap});

  @override
  _DrinkScreenState createState() => _DrinkScreenState();
}

class _DrinkScreenState extends State<DrinkScreen> {
  double _rating = 3.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _showReviewInput = false;
  bool _showReviewSubmittedAnimation = false;

  Future<void> _submitReview() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        CollectionReference reviewsCollection = FirebaseFirestore.instance.collection('drinks').doc(widget.drink.id).collection('reviews');
        QuerySnapshot existingReviews = await reviewsCollection.where('userRef', isEqualTo: FirebaseFirestore.instance.collection('users').doc(user.uid)).get();

        if (existingReviews.docs.isNotEmpty) {
          // Update the existing review
          DocumentSnapshot existingReview = existingReviews.docs.first;
          await existingReview.reference.update({
            'rating': _rating,
            'writtenReview': _reviewController.text,
            'date': Timestamp.now(),
          });
        } else {
          // Create a new review
          await reviewsCollection.add({
            'userRef': FirebaseFirestore.instance.collection('users').doc(user.uid),
            'rating': _rating,
            'writtenReview': _reviewController.text,
            'date': Timestamp.now(),
          });
        }

        await _updateAverageRating();
        FocusScope.of(context).unfocus();

        setState(() {
          _showReviewSubmittedAnimation = true;
          _showReviewInput = !_showReviewInput;
          _reviewController.clear();
          _rating = 3;
        });
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _showReviewSubmittedAnimation = false;
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('review not submitted. please try again.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      );
    }
  }

  String formatRating(double rating) {
    if (rating % 1 == 0) {
      return rating.toStringAsFixed(0);
    } else {
      return rating.toStringAsFixed(2);
    }
  }

  Future<void> _updateAverageRating() async {
    DocumentReference drinkDocRef = FirebaseFirestore.instance.collection('drinks').doc(widget.drink.id);
    QuerySnapshot reviewsSnapshot = await drinkDocRef.collection('reviews').get();
    List<QueryDocumentSnapshot> reviewsDocs = reviewsSnapshot.docs;

    if (reviewsDocs.isNotEmpty) {
      double totalRating = reviewsDocs.fold(0.0, (sum, review) => sum + (review['rating'] as num).toDouble());
      double averageRating = totalRating / reviewsDocs.length;
      await drinkDocRef.update({
        'averageRating': averageRating,
        'ratingsCount': reviewsDocs.length.toDouble(),
      });
    }
  }

  Future<String> _getUserName(DocumentReference userRef) async {
    try {
      DocumentSnapshot userSnapshot = await userRef.get();
      return userSnapshot['name'];
    } catch (e) {
      return "SOBÆR";
    }
  }

  void _launchUrl(String url) async {
    try {
      if (Platform.isAndroid) {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        launchUrl(Uri.parse(url));
      }
    } catch (e) {
      print("error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            widget.drink.name,
            style: TextStyle(fontFamily: 'Anton', color: Theme.of(context).colorScheme.onPrimary),
          ),
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.drink.imageUrl,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      width: MediaQuery.of(context).size.width / 5,
                      height: MediaQuery.of(context).size.width / 2,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'abv: ${widget.drink.abv}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Shimmer.fromColors(
                                baseColor: const Color.fromARGB(255, 247, 119, 87),
                                highlightColor: const Color.fromARGB(255, 234, 152, 131),
                                direction: ShimmerDirection.ltr,
                                child: const Icon(
                                  Icons.star,
                                  color: Color.fromARGB(255, 247, 119, 87),
                                  size: 35,
                                ),
                              ),
                              Text(
                                formatRating(widget.drink.averageRating),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.drink.isVegan)
                            Text(
                              "vegan",
                              style: TextStyle(fontFamily: 'Anton', color: Colors.green.withOpacity(0.8), letterSpacing: 1, fontSize: 20),
                            ),
                          if (widget.drink.calories.isFinite)
                            Text(
                              "${widget.drink.calories.floor()} cals",
                              style: TextStyle(fontFamily: 'Anton', color: const Color.fromARGB(255, 0, 91, 249).withOpacity(0.7), letterSpacing: 1, fontSize: 20),
                            ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.drink.isGlutenFree)
                            Text(
                              "gf",
                              style: TextStyle(fontFamily: 'Anton', color: Colors.red.withOpacity(0.8), letterSpacing: 1, fontSize: 20),
                            ),
                          if (widget.drink.category != "")
                            Text(
                              widget.drink.category,
                              style: const TextStyle(fontFamily: 'Anton', color: draughtColour, letterSpacing: 1, fontSize: 20),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 15),
                Visibility(
                  visible: !_showReviewInput,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showReviewInput = !_showReviewInput;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                              width: 1,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          backgroundColor: wineColour,
                        ),
                        child: Text(
                          "✍️ a review",
                          style: TextStyle(fontFamily: 'Anton', fontSize: 18, color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.onSearchOnMap(widget.drink);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5), // Border radius
                            side: BorderSide(
                              width: 1,
                              color: Theme.of(context).colorScheme.onPrimary, // Solid border color
                            ),
                          ),
                          backgroundColor: canColour,
                        ),
                        child: Text(
                          "on map📍",
                          style: TextStyle(
                            fontFamily: 'Anton',
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      if (widget.drink.buyUrl != null)
                        ElevatedButton(
                          onPressed: () => _launchUrl(widget.drink.buyUrl as String),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // Border radius
                              side: BorderSide(
                                width: 1,
                                color: Theme.of(context).colorScheme.onPrimary, // Solid border color
                              ),
                            ),
                            backgroundColor: spiritColour,
                          ),
                          child: Text(
                            'stock up 📦',
                            style: TextStyle(fontFamily: 'Anton', fontSize: 18, color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _showReviewInput,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('your Rating:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        glowColor: const Color.fromARGB(255, 243, 52, 4),
                        glowRadius: 0,
                        glow: false,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 30,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star_rate_rounded,
                          color: Color.fromARGB(255, 247, 119, 87),
                          size: 10,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _reviewController,
                        decoration: InputDecoration(
                          labelText: 'write a review',
                          floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        cursorColor: Theme.of(context).colorScheme.onPrimary,
                        cursorHeight: 16,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showReviewInput = !_showReviewInput;
                              });
                            },
                            child: Text(
                              'close',
                              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary)),
                            onPressed: _submitReview,
                            child: Text(
                              'submit',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('drinks').doc(widget.drink.id).collection('reviews').orderBy('date', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Text('no reviews yet.');
                    }

                    var reviews = snapshot.data!.docs;
                    if (reviews.isEmpty) {
                      return const Text('no reviews yet.');
                    }

                    double totalRating = reviews.fold(0.0, (totalSum, review) => totalSum + (review['rating'] as num).toDouble());
                    double averageRating = totalRating / reviews.length;
                    FirebaseFirestore.instance.collection('drinks').doc(widget.drink.id).update({
                      'averageRating': averageRating,
                      'ratingsCount': reviews.length.toDouble(),
                    });

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(' ${reviews.length} ${reviews.length > 1 ? 'reviews' : 'review'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Column(
                          children: reviews.map((review) {
                            return ReviewTile(
                              review: review,
                              userNameFuture: _getUserName(review['userRef']),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
                if (_showReviewSubmittedAnimation)
                  Positioned.fill(
                    child: Center(
                      child: Lottie.asset('assets/animations/confetti_review_added.json'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
