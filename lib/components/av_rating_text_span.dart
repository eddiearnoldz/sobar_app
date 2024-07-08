import 'package:flutter/material.dart';

class AvgRatingSpan extends StatelessWidget {
  final String avRating;

  const AvgRatingSpan({super.key, required this.avRating});

  String _processAverageRating(String avRating) {
    if (avRating.endsWith('.0')) {
      return '${avRating.substring(0, avRating.length - 2)}/5';
    }
    return '$avRating/5';
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: 'rating: ',
          ),
          TextSpan(
            text: _processAverageRating(avRating),
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
