import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sobar_app/components/my_text_button.dart';
import 'package:sobar_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            print('Profile image tapped');
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 5),
            child: Icon(
              Icons.person_outline_outlined,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        title: SvgPicture.asset('assets/logos/sobar_logo_square.svg', width: MediaQuery.of(context).size.width / 4),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: BottomAppBar(
        height: 60,
        color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildBottomBarItem(
                icon: Icon(currentPageIndex == 0 ? Icons.map_sharp : Icons.map_outlined,
                    color: currentPageIndex == 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.5), size: 30),
                index: 0),
            buildBottomBarItem(
                icon: Icon(Icons.local_drink, color: currentPageIndex == 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.5), size: 30), index: 1),
            const SizedBox(width: 30), // Placeholder for the FloatingActionButton
            buildBottomBarItem(
                icon: Icon(Icons.mail_outline_sharp, color: currentPageIndex == 2 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.5), size: 30),
                index: 2),
            buildBottomBarItem(
                icon: Icon(Icons.settings, color: currentPageIndex == 3 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.5), size: 30), index: 3),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "TEST - YOU'RE IN",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: MyTextButton(
                buttonText: 'Sign Out',
                onPressed: () {
                  context.read<SignInBloc>().add(SignOutRequired());
                },
                padding: 12,
                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.tertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomBarItem({required Widget icon, required int index}) {
    return Expanded(
      child: TextButton(
        onPressed: () => setState(() => currentPageIndex = index),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use minimal space
          children: [
            icon,
          ],
        ),
      ),
    );
  }
}
