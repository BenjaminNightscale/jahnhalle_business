import 'package:cloud_firestore/cloud_firestore.dart';
import 'drink.dart';  // Import the Drink model

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Drink>> streamDrinks() {
    return _db.collection('drinks').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Drink.fromFirestore(doc)).toList(),
    );
  }
}
