import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:white_label_business_app/themes/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("SettingsPage"),
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(left: 25, right: 25, top: 20),
              padding: const EdgeInsets.all(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Darkmode",
                      style: Theme.of(context).textTheme.displaySmall),
                  CupertinoSwitch(value: Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
                   onChanged: (value) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),),
                ],
              ),
            ),
          ],
        ));
  }
}
