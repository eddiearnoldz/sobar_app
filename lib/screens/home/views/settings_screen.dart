import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sobar_app/screens/settings/views/missing_drinks_screen.dart';
import 'package:sobar_app/screens/settings/views/update_profile.dart';
import 'package:sobar_app/screens/settings/views/useful_links_screen.dart';
import 'package:sobar_app/utils/globals.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Widget> _listItems = [];
  final Duration _initialDelayTime = const Duration(milliseconds: 0);
  final Duration _staggerTime = const Duration(milliseconds: 250);
  bool _showTitle = false;
  User? user;

  @override
  void initState() {
    super.initState();
    _loadListItems();
    _fadeInTitle();
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  Future<void> _fadeInTitle() async {
    await Future.delayed(_initialDelayTime);
    setState(() {
      _showTitle = true;
    });
  }

  Future<void> _loadListItems() async {
    await Future.delayed(_initialDelayTime);

    final items = [
      _buildMenuTile(
        context: context,
        title: 'fun and useful links',
        color: canColour,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UsefulLinksScreen()),
          );
        },
      ),
      _buildMenuTile(
        context: context,
        title: 'profile',
        color: spiritColour,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdateProfileScreen())).then((value) => _refreshUser());
        },
      ),
      _buildMenuTile(
        context: context,
        title: 'did we miss one?',
        color: wineColour,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MissingDrinkScreen()),
          );
        },
      )
    ];

    for (var i = 0; i < items.length; i++) {
      await Future.delayed(_staggerTime);
      _listItems.add(items[i]);
      _listKey.currentState?.insertItem(_listItems.length - 1);
    }
  }

  Widget _buildMenuTile({required BuildContext context, required String title, required Color color, required VoidCallback onTap, double fontSize = 25, bool marginTop = false}) {
    return Container(
      margin: marginTop ? const EdgeInsets.only(top: 100) : const EdgeInsets.symmetric(vertical: 7.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Anton',
            fontSize: fontSize,
            fontStyle: FontStyle.italic,
            letterSpacing: 1,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: false,
        title: AnimatedOpacity(
          opacity: _showTitle ? 1.0 : 0.0,
          duration: const Duration(seconds: 1),
          child: RichText(
            text: TextSpan(
              text: "‘sup ",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
              children: <TextSpan>[
                TextSpan(
                  text: (user?.displayName ?? 'bello'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
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
          ],
        ),
      ),
    );
  }
}
