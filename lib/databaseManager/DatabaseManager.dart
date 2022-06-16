import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseManager {
  final CollectionReference groceryList =
      FirebaseFirestore.instance.collection('Items');
  final CollectionReference cartList =
      FirebaseFirestore.instance.collection('Carts');
  final CollectionReference orderList =
      FirebaseFirestore.instance.collection('UserOrders');
  final CollectionReference favList =
      FirebaseFirestore.instance.collection('Favourite');

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

  getCartLength(uid) async {
    List itemsList = [];

    try {
      Query query = cartList.doc(uid).collection('Item').orderBy("storeName");
      await query.get().then((docs) {
        docs.docs.forEach((doc) {
          itemsList.add(doc);
        });
      });

      return itemsList.length;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Stream? getCartList(uid) {
    try {
      Query query = cartList.doc(uid).collection('Item').orderBy("storeName");
      return query.snapshots();
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Stream? getOrderList(uid) {
    try {
      Query query = orderList.doc(uid).collection('Item').orderBy("storeName");
      return query.snapshots();
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Stream? getFavouriteList(uid) {
    try {
      Query query = favList.doc(uid).collection('Item').orderBy("storeName");
      return query.snapshots();
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
