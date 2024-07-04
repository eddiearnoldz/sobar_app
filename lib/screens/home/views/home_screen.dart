import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sobar_app/screens/home/views/favourite_drinks_screen.dart';
import 'package:sobar_app/screens/home/views/map_screen.dart';
import 'package:sobar_app/screens/home/views/newsletter_screen.dart';
import 'package:sobar_app/screens/home/views/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  final List<Widget> _screens = [
    const MapScreen(), // Placeholder for Map Screen
    const FavoriteDrinksScreen(),
    const NewsletterScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            print('Profile image tapped');
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 5),
            child: Icon(
              Icons.person_outline_outlined,
              size: 30,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        title: SvgPicture.asset('assets/logos/sobar_logo_square.svg', width: MediaQuery.of(context).size.width / 4),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: BottomAppBar(
        elevation: 3,
        height: 60,
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildBottomBarItem(
                icon: Icon(currentPageIndex == 0 ? Icons.map_sharp : Icons.map_outlined,
                    color: currentPageIndex == 0 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimary.withOpacity(0.5), size: 30),
                index: 0),
            buildBottomBarItem(
                icon: Icon(Icons.local_drink, color: currentPageIndex == 1 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimary.withOpacity(0.5), size: 30), index: 1),
            buildBottomBarItem(
                icon: Icon(Icons.mail_outline_sharp, color: currentPageIndex == 2 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimary.withOpacity(0.5), size: 30),
                index: 2),
            buildBottomBarItem(
                icon: Icon(Icons.settings, color: currentPageIndex == 3 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimary.withOpacity(0.5), size: 30), index: 3),
          ],
        ),
      ),
      body: _screens[currentPageIndex],
    );
  }

  Widget buildBottomBarItem({required Widget icon, required int index}) {
    return Expanded(
      child: TextButton(
        onPressed: () => setState(() => currentPageIndex = index),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use minimal space
          children: [
            icon,
          ],
        ),
      ),
    );
  }
}
