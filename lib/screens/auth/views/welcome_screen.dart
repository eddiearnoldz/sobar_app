import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sobar_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:sobar_app/screens/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:sobar_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:sobar_app/screens/auth/views/sign_in_screen.dart';
import 'package:sobar_app/screens/auth/views/sign_up_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/backgrounds/welcome.png",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 130.0),
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 130,
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: SvgPicture.asset(
                            'assets/logos/sobar_logo_title.svg',
                            height: 62,
                            width: 263,
                          )),
                      const SizedBox(
                        height: 110,
                      ),
                      TabBar(
                        dividerHeight: 0,
                        controller: tabController,
                        tabs: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Sign In',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Sign Up',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          )
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            BlocProvider<SignInBloc>(
                              create: (context) => SignInBloc(context.read<AuthenticationBloc>().userRepository),
                              child: const SignInScreen(),
                            ),
                            BlocProvider<SignUpBloc>(
                              create: (context) => SignUpBloc(context.read<AuthenticationBloc>().userRepository),
                              child: const SignUpScreen(),
                            ),
                          ],
                        ),
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
                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 13, fontFamily: 'Work Sans'),
                              ),
                              TextSpan(
                                text: 'www.sobar-app.dev',
                                style:
                                    TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 13, decoration: TextDecoration.underline, fontFamily: 'Work Sans', fontWeight: FontWeight.w700),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
