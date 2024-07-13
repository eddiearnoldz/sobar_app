import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sobar_app/models/drink.dart';

class PubDetailsDrinksOptionTable extends StatefulWidget {
  final Future<Map<String, List<Drink>>> drinkGroupsFuture;

  const PubDetailsDrinksOptionTable({Key? key, required this.drinkGroupsFuture}) : super(key: key);

  @override
  _PubDetailsDrinksOptionTableState createState() => _PubDetailsDrinksOptionTableState();
}

class _PubDetailsDrinksOptionTableState extends State<PubDetailsDrinksOptionTable> {
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['draught', 'can', 'bottle', 'wine', 'spirit'].map((type) {
            int index = ['draught', 'can', 'bottle', 'wine', 'spirit'].indexOf(type);
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPage = index;
                });
              },
              child: Stack(
                children: [
                  Text(
                    '${type}s',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Anton',
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  if (_selectedPage == index)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 2,
                        width: 40,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<Map<String, List<Drink>>>(
            future: widget.drinkGroupsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading drinks'));
              } else {
                final drinkGroups = snapshot.data!;
                final drinksOfType = drinkGroups.values.elementAt(_selectedPage);

                return AnimatedOpacity(
                  opacity: 1,
                  duration: Duration(milliseconds: 500),
                  child: Visibility(
                    visible: true,
                    maintainState: true,
                    child: drinksOfType.isEmpty
                        ? Center(child: Text('No ${drinkGroups.keys.elementAt(_selectedPage)}s at this pub yet'))
                        : ListView.builder(
                            itemCount: drinksOfType.length,
                            itemBuilder: (context, index) {
                              final drink = drinksOfType[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: CachedNetworkImage(
                                        imageUrl: drink.imageUrl,
                                        placeholder: (context, url) => Container(
                                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                                          width: 40,
                                          height: 40,
                                        ),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          drink.name,
                                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                        ),
                                        Text(
                                          'abv: ${drink.abv}',
                                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
