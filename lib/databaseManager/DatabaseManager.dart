import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseManager {
  final CollectionReference groceryList =
      FirebaseFirestore.instance.collection('Items');

  Future getGroceryList(uid) async {
    List itemsList = [];

    try {
      Query query = groceryList.doc(uid).collection('Item').orderBy("itemName");
      await query.get().then((docs) {
        docs.docs.forEach((doc) {
          itemsList.add(doc);
        });
      });

      return itemsList;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
