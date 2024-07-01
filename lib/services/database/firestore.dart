import 'package:cloud_firestore/cloud_firestore.dart';
import 'drink.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Drink>> streamDrinks() {
    return _db.collection('drinks').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Drink.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addDrink(Drink drink) {
    return _db.collection('drinks').add(drink.toMap());
  }

  Future<void> updateDrink(Drink drink) {
    return _db.collection('drinks').doc(drink.id).update(drink.toMap());
  }

  Future<void> deleteDrink(String id) {
    return _db.collection('drinks').doc(id).delete();
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
