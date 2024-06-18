import 'package:flutter/material.dart';
import 'package:white_label_business_app/components/my_button.dart';
import 'package:white_label_business_app/components/my_textfield.dart';
import 'package:white_label_business_app/services/database/drink.dart';
import 'package:white_label_business_app/services/database/firestore.dart';

class CreateDrinkPage extends StatefulWidget {
  @override
  _CreateDrinkPageState createState() => _CreateDrinkPageState();
}

class _CreateDrinkPageState extends State<CreateDrinkPage> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    List<String> categories = await _firestoreService.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _uploadDrink() async {
    String name = _nameController.text;
    String category = _selectedCategory ?? '';
    double price = double.parse(_priceController.text);
    String imageUrl = _imageUrlController.text;
    List<String> ingredients = _ingredientsController.text.split(',').map((e) => e.trim()).toList();
    int quantity = int.parse(_quantityController.text);

    Drink newDrink = Drink(
      id: '',
      name: name,
      category: category,
      price: price,
      imageUrl: imageUrl,
      ingredients: ingredients,
      quantity: quantity,
    );

    await _firestoreService.addDrink(newDrink);

    // Clear the text fields
    _nameController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    _ingredientsController.clear();
    _quantityController.clear();
    setState(() {
      _selectedCategory = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Drink successfully added!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Drink'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyTextField(
                controller: _nameController,
                hintText: 'Name',
                obscureText: false,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              SizedBox(height: 10),
              MyTextField(
                controller: _priceController,
                hintText: 'Price',
                obscureText: false,
              ),
              SizedBox(height: 10),
              MyTextField(
                controller: _imageUrlController,
                hintText: 'Image URL',
                obscureText: false,
              ),
              SizedBox(height: 10),
              MyTextField(
                controller: _ingredientsController,
                hintText: 'Ingredients (comma separated)',
                obscureText: false,
              ),
              SizedBox(height: 10),
              MyTextField(
                controller: _quantityController,
                hintText: 'Quantity',
                obscureText: false,
              ),
              SizedBox(height: 20),
              MyButton(
                text: 'Upload Drink',
                onTap: _uploadDrink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
