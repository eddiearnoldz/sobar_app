import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/components/review_tile.dart';

class DrinkReviewModal extends StatefulWidget {
  final Drink drink;

  const DrinkReviewModal({super.key, required this.drink});

  @override
  _DrinkReviewModalState createState() => _DrinkReviewModalState();
}

class _DrinkReviewModalState extends State<DrinkReviewModal> {
  double _rating = 3.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _showReviewInput = false;

  Future<void> _submitReview() async {
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
    DocumentSnapshot userSnapshot = await userRef.get();
    return userSnapshot['name'] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      snap: true,
      builder: (context, scrollController) {
        return SafeArea(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.drink.name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Anton'),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'abv: ${widget.drink.abv}',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Color.fromARGB(255, 247, 119, 87),
                                          ),
                                          Text(
                                            ': ${widget.drink.averageRating}',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (widget.drink.isVegan)
                                              Text(
                                                "vegan",
                                                style: TextStyle(fontFamily: 'Anton', color: Colors.green.withOpacity(0.8)),
                                              ),
                                            if (widget.drink.calories.isFinite)
                                              Text(
                                                "${widget.drink.calories.floor()} cals",
                                                style: TextStyle(fontFamily: 'Anton', color: const Color.fromARGB(255, 0, 91, 249).withOpacity(0.7)),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (widget.drink.isGlutenFree)
                                              Text(
                                                "gf",
                                                style: TextStyle(fontFamily: 'Anton', color: Colors.red.withOpacity(0.8)),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      CachedNetworkImage(
                        imageUrl: widget.drink.imageUrl,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        width: MediaQuery.of(context).size.width / 5,
                        height: MediaQuery.of(context).size.width / 3,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Visibility(
                      visible: !_showReviewInput,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                          foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                          side: MaterialStateProperty.all(BorderSide(color: Theme.of(context).colorScheme.onPrimary)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Leave a review",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 14,
                            )
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            _showReviewInput = !_showReviewInput;
                          });
                        },
                      )),
                  Visibility(
                    visible: _showReviewInput,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Rating:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                            labelText: 'Write a review',
                            floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 05),
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
                                'Cancel',
                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary)),
                              onPressed: _submitReview,
                              child: Text(
                                'Submit',
                                style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
                        return const Text('No reviews yet.');
                      }

                      var reviews = snapshot.data!.docs;
                      if (reviews.isEmpty) {
                        return const Text('No reviews yet.');
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
