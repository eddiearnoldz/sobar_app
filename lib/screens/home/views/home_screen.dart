import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location/location.dart';
import 'package:sobar_app/models/adPopUp.dart';
import 'package:sobar_app/screens/admin/admin_screen.dart';
import 'package:sobar_app/screens/home/views/new_map_screen.dart';
import 'package:sobar_app/screens/home/views/drinks_screen.dart';
import 'package:sobar_app/screens/home/views/newsletter_screen.dart';
import 'package:sobar_app/screens/home/views/settings_screen.dart';
import 'package:sobar_app/utils/ad_pop_up_manager.dart';
import 'package:sobar_app/utils/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;
  bool isAdmin = false;

  final List<Widget> _screens = [
    const NewMapScreen(),
    const DrinksScreen(),
    const NewsletterScreen(),
    const SettingsScreen(),
  ];

  final LocationService locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _checkAdPopup();
    _checkAdminStatus();
  }

  void _checkAdPopup() async {
    AdPopUpService adService = AdPopUpService();
    AdPopUp? adPopUp = await adService.getAdPopUp();
    if (adPopUp != null) {
      AdPopupManager adPopupManager = AdPopupManager();
      await adPopupManager.showAdPopupIfNeeded(context, adPopUp);
    }
  }

  Future<void> _checkAdminStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        isAdmin = userDoc['admin'] ?? false;
        if (isAdmin) {
          _screens.add(const AdminScreen());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: currentPageIndex != 0
          ? AppBar(
              toolbarHeight: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              title: SvgPicture.asset('assets/logos/sobar_logo_square.svg', width: MediaQuery.of(context).size.width / 5, color: Theme.of(context).colorScheme.onPrimary),
              centerTitle: true,
            )
          : null,
      backgroundColor: Theme.of(context).colorScheme.primary,
      bottomNavigationBar: BottomAppBar(
        elevation: 3,
        height: 55,
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildBottomBarItem(
                icon: SvgPicture.asset(
                  currentPageIndex == 0 ? "assets/icons/icon_map_filled.svg" : "assets/icons/icon_map_line.svg",
                  color: currentPageIndex == 0 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                ),
                index: 0),
            buildBottomBarItem(
                icon: SvgPicture.asset(
                  "assets/icons/icon_pint_outline.svg",
                  color: currentPageIndex == 1 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                  height: 30,
                  width: 30,
                ),
                index: 1),
            buildBottomBarItem(
                icon: SvgPicture.asset(
                  "assets/icons/icon_newsletter.svg",
                  color: currentPageIndex == 2 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                  height: 30,
                  width: 30,
                ),
                index: 2),
            buildBottomBarItem(
                icon: SvgPicture.asset(
                  "assets/icons/icon_settings.svg",
                  color: currentPageIndex == 3 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                  height: 30,
                  width: 30,
                ),
                index: 3),
            if (isAdmin)
              buildBottomBarItem(
                icon: SvgPicture.asset(
                  "assets/icons/icon_tool.svg",
                  color: currentPageIndex == 4 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                  height: 30,
                  width: 30,
                ),
                index: 4,
              ),
          ],
        ),
      ),
      body: _screens[currentPageIndex],
    );
  }

  Widget buildBottomBarItem({required Widget icon, required int index}) {
    return Expanded(
      flex: 0,
      child: TextButton(
        onPressed: () => setState(() => currentPageIndex = index),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
          ],
        ),
      ),
    );
  }
}
