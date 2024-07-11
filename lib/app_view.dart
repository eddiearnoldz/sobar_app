import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:sobar_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:sobar_app/blocs/drink_bloc/drink_bloc.dart';
import 'package:sobar_app/blocs/pub_bloc/pub_bloc.dart';
import 'package:sobar_app/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:sobar_app/screens/auth/views/welcome_screen.dart';
import 'package:sobar_app/screens/home/views/home_screen.dart';
import 'package:sobar_app/utils/api_key_helper.dart';
import 'package:sobar_app/blocs/map_bloc/map_bloc.dart';
import 'package:sobar_app/utils/map_provider.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapProvider(),
      child: MaterialApp(
        title: 'SOBÆR',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: HexColor("#FCF4F0"),
          colorScheme: ColorScheme.light(
            surface: HexColor("#FCF4F0"),
            onSurface: HexColor("#1C1C1C"),
            primary: HexColor("#FCF4F0"),
            onPrimary: HexColor("#1C1C1C"),
            secondary: HexColor('#FFFFFF'),
            onSecondary: HexColor('#FCF4F0'),
            error: HexColor("#FB0606"),
          ),
          fontFamily: 'Work Sans',
          focusColor: HexColor("#FBF6C7"),
        ),
        darkTheme: ThemeData(
          primaryColor: HexColor("#1C1C1C"), // Inverted from #FCF4F0
          colorScheme: ColorScheme.dark(
            surface: HexColor("#1C1C1C"), // Inverted from #FCF4F0
            onSurface: HexColor("#FCF4F0"), // Inverted from #1C1C1C
            primary: HexColor("#1C1C1C"), // Inverted from #FCF4F0
            onPrimary: HexColor("#FCF4F0"), // Inverted from #1C1C1C
            secondary: HexColor('#1C1C1C'),
            onSecondary: HexColor('#FFFFFF'),
            error: HexColor("#FB0606"), // Kept the same for consistency
          ),
          fontFamily: 'Work Sans',
          focusColor: HexColor("#1C1C1C"), // Dark background for focus color
        ),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state.status == AuthenticationStatus.authenticated) {
              storeApiKeys();
              return MultiBlocProvider(
                providers: [
                  BlocProvider<SignInBloc>(
                    create: (context) => SignInBloc(context.read<AuthenticationBloc>().userRepository),
                  ),
                  BlocProvider<PubBloc>(
                    create: (context) => PubBloc(firestore: FirebaseFirestore.instance)..add(LoadPubs()),
                  ),
                  BlocProvider<DrinkBloc>(
                    create: (context) => DrinkBloc(firestore: FirebaseFirestore.instance)..add(LoadDrinks()),
                  ),
                  BlocProvider<MapBloc>(
                    create: (context) => MapBloc(context.read<MapProvider>()),
                  ),
                ],
                child: const HomeScreen(),
              );
            } else if (state.status == AuthenticationStatus.unauthenticated) {
              return const WelcomeScreen();
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
