import 'package:flutter/material.dart';
import 'package:sobar_app/components/admin_option_tile.dart';
import 'package:sobar_app/utils/globals.dart';
import 'package:sobar_app/screens/admin/add_venue_screen.dart';
import 'package:sobar_app/screens/admin/add_drinks_to_venue_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Widget> _listItems = [];
  final Duration _initialDelayTime = const Duration(milliseconds: 0);
  final Duration _staggerTime = const Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _loadListItems();
  }

  Future<void> _loadListItems() async {
    await Future.delayed(_initialDelayTime);

    final items = [
      AdminOptionTile(
        title: 'add drinks to a venue',
        iconPath: "assets/icons/icon_pint_outline.svg",
        color: wineColour,
        onTap: () => _navigateToAddDrinksToVenue(context),
      ),
      AdminOptionTile(
        title: 'add a venue to the database',
        iconPath: "assets/icons/icon_venue.svg",
        color: bottleColour,
        onTap: () => _navigateToAddVenue(context),
      ),
    ];

    for (var i = 0; i < items.length; i++) {
      await Future.delayed(_staggerTime);
      _listItems.add(items[i]);
      _listKey.currentState?.insertItem(_listItems.length - 1);
    }
  }

  void _navigateToAddDrinksToVenue(BuildContext context) {
    Navigator.of(context).push(_createRoute(const AddDrinksToVenueScreen()));
  }

  void _navigateToAddVenue(BuildContext context) {
    Navigator.of(context).push(_createRoute(const AddVenueScreen()));
  }

  Route _createRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Screen'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: AnimatedList(
            key: _listKey,
            initialItemCount: _listItems.length,
            itemBuilder: (context, index, animation) {
              final beginOffset = index % 2 == 0 ? const Offset(-1, 0) : const Offset(1, 0);
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(begin: beginOffset, end: Offset.zero).chain(
                    CurveTween(curve: Curves.fastEaseInToSlowEaseOut),
                  ),
                ),
                child: _listItems[index],
              );
            },
          ),
        ),
      ),
    );
  }
}
