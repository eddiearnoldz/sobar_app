import 'package:flutter/material.dart';

class OpeningHoursTable extends StatelessWidget {
  final List<dynamic> openingHours;
  final bool showOpeningHours;

  const OpeningHoursTable({
    super.key,
    required this.openingHours,
    required this.showOpeningHours,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: showOpeningHours ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: showOpeningHours,
        maintainState: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),
            Text(
              "Opening Hours: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: openingHours.sublist(0, (openingHours.length / 2).ceil()).map<Widget>((day) {
                    return Text(
                      day,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                      ),
                    );
                  }).toList(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: openingHours.sublist((openingHours.length / 2).ceil()).map<Widget>((day) {
                    return Text(
                      day,
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
