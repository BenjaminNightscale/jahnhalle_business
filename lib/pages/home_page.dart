import 'package:flutter/material.dart';
import 'package:white_label_business_app/components/my_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: const MyDrawer(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
          },
          child: const Text('Zur DetailsPage wechseln'),
        ),
      ),
    );
  }
}
