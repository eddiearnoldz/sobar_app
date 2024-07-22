import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:sobar_app/models/pub.dart';

class FilterPubResultsList extends StatelessWidget {
  final List<Pub> filteredPubs;
  final Function(Pub, TextEditingController) onPubSelected;
  final TextEditingController pubSearchController;
  final bool isBlackStyle;
  final FocusNode focusNode;

  const FilterPubResultsList({
    super.key,
    required this.filteredPubs,
    required this.isBlackStyle,
    required this.onPubSelected,
    required this.pubSearchController,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    Color gradientColor = isBlackStyle ? HexColor("#212121") : HexColor("#FCF4F0");
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          color: Colors.white.withOpacity(0.5),
          height: MediaQuery.of(context).size.height * .5,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: filteredPubs.length,
            itemBuilder: (context, index) {
              final pub = filteredPubs[index];
              return GestureDetector(
                onTap: () => {onPubSelected(pub, pubSearchController), focusNode.unfocus(), pubSearchController.clear()},
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
        ),
        Container(
          height: MediaQuery.of(context).size.height * .05,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gradientColor.withOpacity(0.0), // Transparent at the top
                gradientColor.withOpacity(0.5), // Semi-transparent
                gradientColor.withOpacity(1.0), // Fully opaque at the bottom
              ],
            ),
          ),
        ),
      ],
    );
  }
}
