import 'package:flutter/material.dart';
import 'package:sobar_app/models/drink.dart';

class SelectedDrinkFilterClearButton extends StatelessWidget {
  final Drink selectedDrink;
  final Function onClear;

  const SelectedDrinkFilterClearButton({
    super.key,
    required this.selectedDrink,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 10,
      child: GestureDetector(
        onTap: () => onClear(),
        child: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                image: DecorationImage(
                  image: NetworkImage(selectedDrink.imageUrl),
                  fit: BoxFit.contain,
                ),
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
      ),
    );
  }
}
