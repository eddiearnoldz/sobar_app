import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobar_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:sobar_app/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:sobar_app/screens/settings/views/useful_links_screen.dart';
import 'package:sobar_app/utils/globals.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthenticationBloc>().state.user;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: false,
        title: RichText(
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
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
        child: Column(
          children: [
            ListTile(
              title: Text(
                'fun and useful links',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold, fontFamily: 'Anton', fontSize: 25, fontStyle: FontStyle.italic, letterSpacing: 1),
              ),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UsefulLinksScreen()),
                );
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              tileColor: canColour,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            const SizedBox(height: 15),
            ListTile(
              title: Text(
                'update profile',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold, fontFamily: 'Anton', fontSize: 25, fontStyle: FontStyle.italic, letterSpacing: 1),
              ),
              onTap: () async {},
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              tileColor: spiritColour,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            const SizedBox(height: 15),
            ListTile(
              title: Text(
                'did we miss one?',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold, fontFamily: 'Anton', fontSize: 25, fontStyle: FontStyle.italic, letterSpacing: 1),
              ),
              onTap: _sendEmail,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              tileColor: wineColour,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            Spacer(),
            ListTile(
              title: Text(
                'SigN OuT',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold, fontFamily: 'Anton', fontSize: 50, fontStyle: FontStyle.italic, letterSpacing: 1),
              ),
              onTap: () async {
                context.read<SignInBloc>().add(SignOutRequired());
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setInt(openCountKey, 0);
                print(prefs.getInt(openCountKey));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              tileColor: bottleColour,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
