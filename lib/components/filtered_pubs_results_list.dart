import 'package:flutter/material.dart';
import 'package:sobar_app/models/pub.dart';

class FilterPubResultsList extends StatelessWidget {
  final List<Pub> filteredPubs;
  final Function(Pub, TextEditingController) onPubSelected;
  final TextEditingController pubSearchController;

  const FilterPubResultsList({
    super.key,
    required this.filteredPubs,
    required this.onPubSelected,
    required this.pubSearchController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filteredPubs.length,
        itemBuilder: (context, index) {
          final pub = filteredPubs[index];
          return GestureDetector(
            onTap: () => onPubSelected(pub, pubSearchController),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(top: 5, left: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pub.locationName, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                        Text(
                          pub.locationAddress,
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
