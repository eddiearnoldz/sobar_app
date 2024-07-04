import 'package:flutter/material.dart';

class FavoriteDrinksScreen extends StatelessWidget {
  const FavoriteDrinksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "FAVOURITE DRINKS SCREEN",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
