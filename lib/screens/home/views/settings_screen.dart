import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobar_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:sobar_app/components/my_text_button.dart';
import 'package:sobar_app/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:sobar_app/utils/globals.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthenticationBloc bloc) => bloc.state.user);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          centerTitle: false,
          title: RichText(
            text: TextSpan(
              text: "‘sup ",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '${user?.name}' ?? 'bello',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "SETTINGS SCREEN",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: MyTextButton(
                  buttonText: 'Sign Out',
                  onPressed: () async {
                    context.read<SignInBloc>().add(SignOutRequired());
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setInt(openCountKey, 0);
                        print(prefs.getInt(openCountKey));
                  },
                  padding: 12,
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ));
  }
}
