import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sobar_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:sobar_app/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:sobar_app/screens/auth/views/sign_in_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  void _navigateToSignIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider<SignInBloc>(
          create: (context) => SignInBloc(context.read<AuthenticationBloc>().userRepository),
          child: const SignInScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/backgrounds/welcome_background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
              child: Container(
            color: Colors.black.withOpacity(0.3),
          )),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(flex: 1),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SvgPicture.asset(
                      'assets/logos/sobar_logo_light_grey.svg',
                      height: 62,
                      width: 263,
                    )),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "If you're staying on the wagon or thank you in Italian this is the app for you.",
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(flex: 2),
                ElevatedButton(
                  onPressed: () => _navigateToSignIn(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(fontFamily: 'Anton', fontSize: 18, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
                GestureDetector(
                  onTap: () {
                    String url = "https://www.burnleyfootballclub.com";
                    try {
                      if (Platform.isAndroid) {
                        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } else {
                        launchUrl(Uri.parse(url));
                      }
                    } catch (e) {}
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'discover more at ',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13, fontFamily: 'Work Sans'),
                        ),
                        TextSpan(
                          text: 'www.sobær-app.dev',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13, decoration: TextDecoration.underline, fontFamily: 'Work Sans', fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
