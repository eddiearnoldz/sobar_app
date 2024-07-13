import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sobar_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:sobar_app/components/my_text_button.dart';
import 'package:sobar_app/components/my_text_field.dart';
import 'package:sobar_app/screens/auth/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:sobar_app/screens/auth/blocs/sign_up_bloc/sign_up_bloc.dart'; // Import the SignUpBloc
import 'package:sobar_app/screens/auth/views/sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool signInRequired = false;
  bool obscurePassword = true;
  String? _errMessage;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          setState(() {
            signInRequired = false;
          });
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is SignInProcess) {
          signInRequired = true;
        } else if (state is SignInFailure) {
          setState(() {
            signInRequired = false;
            _errMessage = 'Invalid email or password';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _errMessage ?? 'An error occurred during sign-in.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.surface),
              ),
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          body: Stack(children: [
            Positioned.fill(
              child: Image.asset(
                "assets/backgrounds/sign_in_beer_background.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
                child: Container(
              color: Colors.black.withOpacity(0.5),
            )),
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: MyTextField(
                          controller: emailController,
                          hintText: 'email',
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please fill in the email field';
                            } else if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: MyTextField(
                          controller: passwordController,
                          hintText: 'password',
                          obscureText: obscurePassword,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'please fill in the password field';
                            } else {
                              return null;
                            }
                          },
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                                if (obscurePassword) {
                                  iconPassword = CupertinoIcons.eye_fill;
                                } else {
                                  iconPassword = CupertinoIcons.eye_slash;
                                }
                              });
                            },
                            icon: Icon(iconPassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      !signInRequired
                          ? ElevatedButton(
                              onPressed: () => {
                                FocusScope.of(context).unfocus(),
                                if (_formKey.currentState!.validate()) {context.read<SignInBloc>().add(SignInRequired(emailController.text, passwordController.text))},
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                              ),
                              child: Text(
                                'sign in',
                                style: TextStyle(fontFamily: 'Anton', fontSize: 18, color: Theme.of(context).colorScheme.onPrimary),
                              ),
                            )
                          : const CircularProgressIndicator(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => SignUpBloc(context.read<AuthenticationBloc>().userRepository),
                          child: const SignUpScreen(),
                        ),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'not registered yet? ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      children: const <TextSpan>[
                        TextSpan(
                          text: 'sign up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ))
          ]),
        ),
      ),
    );
  }
}
