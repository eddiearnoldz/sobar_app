import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReviewTile extends StatelessWidget {
  final QueryDocumentSnapshot review;
  final Future<String> userNameFuture;

  ReviewTile({required this.review, required this.userNameFuture});

  @override
  Widget build(BuildContext context) {
    double rating = (review['rating'] as num).toDouble();
    DateTime reviewDate = (review['date'] as Timestamp).toDate();
    String formattedDate = DateFormat('dd/MM/yyyy').format(reviewDate);

    return FutureBuilder<String>(
      future: userNameFuture,
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        String userName = userSnapshot.data!;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            title: Text(review['writtenReview']),
            minVerticalPadding: 5,
            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Rating: $rating', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onPrimary)),
                    const SizedBox(width: 5),
                    Row(
                      children: List.generate(5, (starIndex) {
                        double currentStarValue = starIndex + 1;
                        if (currentStarValue <= rating) {
                          return const Icon(Icons.star_rounded, size: 12, color: Color.fromARGB(255, 247, 119, 87));
                        } else if (currentStarValue - 0.5 == rating) {
                          return const Icon(Icons.star_half_rounded, size: 12, color: Color.fromARGB(255, 247, 119, 87));
                        } else {
                          return const Icon(Icons.star_border_rounded, size: 12, color: Color.fromARGB(255, 247, 119, 87));
                        }
                      }),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Text('$userName - $formattedDate', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onPrimary)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
