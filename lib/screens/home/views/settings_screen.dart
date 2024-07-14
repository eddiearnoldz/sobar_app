import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobar_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:sobar_app/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:sobar_app/screens/settings/views/useful_links_screen.dart';
import 'package:sobar_app/utils/globals.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Widget> _listItems = [];
  final Duration _initialDelayTime = const Duration(milliseconds: 0);
  final Duration _itemSlideTime = const Duration(milliseconds: 250);
  final Duration _staggerTime = const Duration(milliseconds: 250);
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _loadListItems();
    _fadeInTitle();
  }

  Future<void> _fadeInTitle() async {
    await Future.delayed(_initialDelayTime);
    setState(() {
      _showTitle = true;
    });
  }

  Future<void> _sendEmail() async {
    print("creating email");
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'sobær-app-info@me.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Missing Drink on SOBÆR App',
        'body':
            'Hey looks like my new favourite pub has a drink that SOBÆR doesn\'t have on the map yet. Could you please add it?\n\nDRINK: <your drink here>\nPUB:<name of pub>\nCITY:<city>\nNAME:<your name>',
      }),
    );

    try {
      if (Platform.isAndroid) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(emailUri);
      }
    } catch (e) {
      print("error: $e");
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries.map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
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
        title: 'update profile',
        color: spiritColour,
        onTap: () {},
      ),
      _buildMenuTile(
        context: context,
        title: 'did we miss one?',
        color: wineColour,
        onTap: _sendEmail,
      ),
      _buildMenuTile(
          context: context,
          title: 'SigN OuT',
          color: bottleColour,
          onTap: () async {
            context.read<SignInBloc>().add(SignOutRequired());
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setInt(openCountKey, 0);
            print(prefs.getInt(openCountKey));
          },
          fontSize: 50,
          marginTop: true),
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
    final user = context.read<AuthenticationBloc>().state.user;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: false,
        title: AnimatedOpacity(
          opacity: _showTitle ? 1.0 : 0.0,
          duration: Duration(seconds: 1),
          child: RichText(
            text: TextSpan(
              text: "‘sup ",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 18),
              children: <TextSpan>[
                TextSpan(
                  text: '${user?.name}' ?? 'bello',
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
