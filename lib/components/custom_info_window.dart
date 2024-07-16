import 'package:flutter/material.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/utils/globals.dart';

class CustomInfoWindow extends StatelessWidget {
  final Pub pub;

  const CustomInfoWindow({super.key, required this.pub});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.onPrimary,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 4,
                  child: Text(
                    pub.locationName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontFamily: 'Anton', letterSpacing: 1),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: _buildDrinkTypeIndicators(),
                  ),
                ),
              ],
            ),
            Text(
              pub.locationAddress,
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDrinkTypeIndicators() {
    List<Widget> indicators = [];
    if (pub.drinksData.any((drink) => drink.type == 'draught')) {
      indicators.add(_buildIndicator(draughtColour));
    }
    if (pub.drinksData.any((drink) => drink.type == 'bottle')) {
      indicators.add(_buildIndicator(bottleColour));
    }
    if (pub.drinksData.any((drink) => drink.type == 'can')) {
      indicators.add(_buildIndicator(canColour));
    }
    if (pub.drinksData.any((drink) => drink.type == 'wine')) {
      indicators.add(_buildIndicator(wineColour));
    }
    if (pub.drinksData.any((drink) => drink.type == 'spirit')) {
      indicators.add(_buildIndicator(spiritColour));
    }
    return indicators;
  }

  Widget _buildIndicator(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(right: 3),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
