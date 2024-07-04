import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sobar_app/components/my_text_button.dart';
import 'package:sobar_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "SETTINGS SCREEN",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: MyTextButton(
              buttonText: 'Sign Out',
              onPressed: () {
                context.read<SignInBloc>().add(SignOutRequired());
              },
              padding: 12,
              backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
