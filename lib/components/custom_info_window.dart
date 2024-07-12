import 'package:flutter/material.dart';
import 'package:sobar_app/models/pub.dart';

class CustomInfoWindow extends StatelessWidget {
  final Pub pub;

  const CustomInfoWindow({Key? key, required this.pub}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
                Text(
                  pub.locationName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: _buildDrinkTypeIndicators(),
                ),
              ],
            ),
            Text(
              pub.locationAddress,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDrinkTypeIndicators() {
    List<Widget> indicators = [];
    if (pub.drinksData.any((drink) => drink.type == 'draught')) {
      indicators.add(_buildIndicator(Colors.purple));
    }
    if (pub.drinksData.any((drink) => drink.type == 'bottle')) {
      indicators.add(_buildIndicator(Colors.red));
    }
    if (pub.drinksData.any((drink) => drink.type == 'can')) {
      indicators.add(_buildIndicator(Colors.blue));
    }
    if (pub.drinksData.any((drink) => drink.type == 'wine')) {
      indicators.add(_buildIndicator(Colors.green));
    }
    if (pub.drinksData.any((drink) => drink.type == 'spirit')) {
      indicators.add(_buildIndicator(Colors.yellow));
    }
    return indicators;
  }

  Widget _buildIndicator(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: EdgeInsets.only(right: 3),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
