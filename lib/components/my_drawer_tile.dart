import 'package:flutter/material.dart';

class MyDrawerTile extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Function() onTap;

  const MyDrawerTile({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left :25.0),
      child: ListTile(
        title: Text(text, style: Theme.of(context).textTheme.displaySmall),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        onTap: onTap,
      ),
    );
  }
}
