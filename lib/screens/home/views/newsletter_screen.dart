import 'package:flutter/material.dart';

class NewsletterScreen extends StatelessWidget {
  const NewsletterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "NEWSLETTER SCREEN",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
