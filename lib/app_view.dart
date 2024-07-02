import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:sobar_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:sobar_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:sobar_app/screens/auth/views/welcome_screen.dart';
import 'package:sobar_app/screens/home/views/home_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'SOBAR',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: HexColor("#DBDAD9"),
            colorScheme: ColorScheme.light(
              surface: HexColor("#DBDAD9"),
              onSurface: HexColor("#DBDAD9"),
              primary: HexColor("#292829"),
              onPrimary: HexColor("#292829"),
              error: HexColor("#FB0606"),
            ),
            fontFamily: 'Work Sans',
            focusColor: HexColor("#FBF6C7")),
        darkTheme: ThemeData.dark(),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: ((context, state) {
            if (state.status == AuthenticationStatus.authenticated) {
              return BlocProvider<SignInBloc>(
                create: (context) => SignInBloc(context.read<AuthenticationBloc>().userRepository),
                child: const HomeScreen(),
              );
            } else {
              return const WelcomeScreen();
            }
          }),
        ));
  }
}
