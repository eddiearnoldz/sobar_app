import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sobar_app/models/drink.dart';

class SelectedDrinkFilterClearButton extends StatelessWidget {
  final Drink selectedDrink;
  final Function(TextEditingController) onClear;
  final TextEditingController drinkSearchController;

  const SelectedDrinkFilterClearButton({
    Key? key,
    required this.selectedDrink,
    required this.onClear,
    required this.drinkSearchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClear(drinkSearchController),
      child: Stack(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: CachedNetworkImage(
              imageUrl: selectedDrink.imageUrl,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 10),
            ),
          ),
        ],
      ),
    );
  }
}
