import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sobar_app/components/my_text_field.dart';
import 'package:sobar_app/screens/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:user_repository/user_repository.dart';
// Import SignInScreen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool signUpRequired = false;
  bool obscurePassword = true;
  String? _errMessage;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          setState(() {
            signUpRequired = false;
          });
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is SignUpProcess) {
          setState(() {
            signUpRequired = true;
          });
        } else if (state is SignUpFailure) {
          setState(() {
            _errMessage = state.errorMessage.contains('email-already-in-use') ? 'The email address is already in use by another account.' : state.errorMessage;
            signUpRequired = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _errMessage ?? 'An error occurred during sign-up.',
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
                "assets/backgrounds/sign_up_background.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
                child: Container(
              color: Colors.black.withOpacity(0.3),
            )),
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                              return 'Please fill in the password field';
                            } else if (!RegExp(
                              r'^(?=.*[a-z])(?=.*[A-Z]).{8,}$',
                            ).hasMatch(value)) {
                              return 'Lower and uppercase letters, and be at least 8 characters long';
                            }
                            return null;
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: MyTextField(
                          controller: nameController,
                          hintText: 'name',
                          obscureText: false,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'please fill in the name field';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      !signUpRequired
                          ? ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                if (_formKey.currentState!.validate()) {
                                  MyUser myUser = MyUser.empty;
                                  myUser.email = emailController.text;
                                  myUser.name = nameController.text;
                                  setState(() {
                                    context.read<SignUpBloc>().add(SignUpRequired(myUser, passwordController.text));
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                              ),
                              child: Text(
                                'sign up',
                                style: TextStyle(fontFamily: 'Anton', fontSize: 18, color: Theme.of(context).colorScheme.onPrimary),
                              ),
                            )
                          : const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Navigate back to sign-in screen
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'already registered? ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            children: const <TextSpan>[
                              TextSpan(
                                text: 'sign in',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
