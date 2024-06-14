import 'package:flutter/material.dart';
import 'package:white_label_business_app/components/my_drawer_tile.dart';
import 'package:white_label_business_app/pages/settings_page.dart';
import 'package:white_label_business_app/services/auth/auth_service.dart';


import '../pages/profile_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    // Add logout functionality here
    final authService = AuthService();
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Icon(
                Icons.account_circle,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            MyDrawerTile(
              text: 'Home',
              icon: Icons.home,
              onTap: () => Navigator.pop(context),
            ),
            MyDrawerTile(
              text: 'Profile',
              icon: Icons.account_circle,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
            ),
            MyDrawerTile(
              text: 'Settings',
              icon: Icons.settings,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),
            const Spacer(),
            MyDrawerTile(
              text: 'Logout',
              icon: Icons.logout,
              onTap: logout,
            ),
            const SizedBox(height: 25),
          ],
        ));
  }
}
