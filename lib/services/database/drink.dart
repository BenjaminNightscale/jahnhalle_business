import 'package:cloud_firestore/cloud_firestore.dart';

class Drink {
  String id;
  String name;
  String category;
  double price; // Assuming price is a double
  String imageUrl; // Assuming image URL is stored as a string
  List<String> ingredients; // Assuming ingredients are stored as a list of strings
  int quantity; // Add the quantity field

  Drink({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.ingredients,
    this.quantity = 0, // Initialize quantity with a default value
  });

  factory Drink.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Drink(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(), // Ensure it handles null & convert to double
      imageUrl: data['imageUrl'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []), // Convert any List to List<String>
      quantity: data['quantity'] ?? 0, // Handle quantity from Firestore
    );
  }
}
