import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:white_label_business_app/components/my_app_bar.dart';
import 'package:white_label_business_app/pages/edit_drinks_page.dart';
import 'package:white_label_business_app/services/database/drink.dart';
import 'package:white_label_business_app/themes/dark_mode.dart';

class DrinkListPage extends StatefulWidget {
  @override
  _DrinkListPageState createState() => _DrinkListPageState();
}

class _DrinkListPageState extends State<DrinkListPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: darkMode,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: const CustomAppBar(title: 'Drinks'),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('drinks').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var drinks = snapshot.data!.docs
                        .map((doc) => Drink.fromFirestore(doc))
                        .where((drink) => drink.name.toLowerCase().contains(searchQuery.toLowerCase()))
                        .toList()
                      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                    if (drinks.isEmpty) {
                      return Center(child: Text('No drinks found', style: Theme.of(context).textTheme.bodyMedium));
                    }

                    return ListView.builder(
                      itemCount: drinks.length,
                      itemBuilder: (context, index) {
                        final drink = drinks[index];
                        return ListTile(
                          leading: drink.imageUrl.isNotEmpty
                              ? Image.network(drink.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt_outlined, color: Colors.grey[500]),
                                    ],
                                  ),
                                ),
                          title: Text(drink.name, style: Theme.of(context).textTheme.bodyLarge),
                          subtitle: Text(
                            'Category: ${drink.category}\nPrice: \$${drink.price}\nQuantity: ${drink.quantity}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          onTap: () => _showEditDrinkModal(context, drink),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDrinkModal(BuildContext context, Drink drink) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9, // Initial size of the modal
          minChildSize: 0.9, // Minimum size when dragging down
          maxChildSize: 0.9, // Maximum size when dragging up
          builder: (context, scrollController) {
            return EditDrinkPage(drink: drink);
          },
        );
      },
    );
  }
}
