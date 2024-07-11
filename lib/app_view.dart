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
          primaryColor: HexColor("#DBDAD9"),
          colorScheme: ColorScheme.light(
            surface: HexColor("#DBDAD9"),
            onSurface: HexColor("#292829"),
            primary: HexColor("#DBDAD9"),
            onPrimary: HexColor("#292829"),
            secondary: HexColor('#FFFFFF'),
            onSecondary: HexColor('#DBDAD9'),
            error: HexColor("#FB0606"),
          ),
          fontFamily: 'Work Sans',
          focusColor: HexColor("#FBF6C7"),
        ),
        darkTheme: ThemeData(
          primaryColor: HexColor("#292829"), // Inverted from #DBDAD9
          colorScheme: ColorScheme.dark(
            surface: HexColor("#292829"), // Inverted from #DBDAD9
            onSurface: HexColor("#DBDAD9"), // Inverted from #292829
            primary: HexColor("#292829"), // Inverted from #DBDAD9
            onPrimary: HexColor("#DBDAD9"), // Inverted from #292829
            secondary: HexColor('#292829'),
            onSecondary: HexColor('#FFFFFF'),
            error: HexColor("#FB0606"), // Kept the same for consistency
          ),
          fontFamily: 'Work Sans',
          focusColor: HexColor("#292829"), // Dark background for focus color
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
                    create: (context) => MapBloc(),
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
