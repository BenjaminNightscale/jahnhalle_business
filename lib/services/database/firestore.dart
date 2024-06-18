import 'package:cloud_firestore/cloud_firestore.dart';
import 'drink.dart'; // Import the Drink model

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Drink>> streamDrinks() {
    return _db.collection('drinks').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Drink.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addDrink(Drink drink) {
    return _db.collection('drinks').add(drink.toMap());
  }

  Future<List<String>> getCategories() async {
    QuerySnapshot snapshot = await _db.collection('drinks').get();
    Set<String> categories = {};
    for (var doc in snapshot.docs) {
      categories.add(doc['category']);
    }
    return categories.toList();
  }
}
