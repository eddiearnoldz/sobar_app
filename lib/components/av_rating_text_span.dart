import 'package:flutter/material.dart';

class AvgRatingSpan extends StatelessWidget {
  final String avRating;

  const AvgRatingSpan({super.key, required this.avRating});

  String _processAverageRating(String avRating) {
    if (avRating.endsWith('.0')) {
      return ': ${avRating.substring(0, avRating.length - 2)}';
    }
    return ': $avRating';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.star,
          color: Color.fromARGB(255, 247, 119, 87),
          size: 15,
        ),
        Text.rich(
          TextSpan(
            children: [
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
        ),
      ],
    );
  }
}
