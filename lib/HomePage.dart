import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery_user/ProfilePage.dart';
import 'package:flutter_grocery_user/databaseManager/DatabaseManager.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'AddItem.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;
  User? currentUser = FirebaseAuth.instance.currentUser;
  TextEditingController searchController = TextEditingController();

  bool isLoggedin = true;
  bool _isEdit = false;

  List groceryItemList = [];
  List nameList = [];
  List itemsIdList = [];
  List items = [];

  late List groceries;

  int _selectedIndex = 0;

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void initState() {
    super.initState();
    fetchGroceryItemList();
    fetchItemId();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  fetchGroceryItemList() async {
    dynamic resultant = await DatabaseManager().getGroceryList(currentUser);
    if (resultant == null) {
      print("Unable to retrieve");
    } else {
      setState(() {
        groceryItemList = resultant;
        groceryItemList.forEach((e) => nameList.add(e["itemName"]));
        items.addAll(groceryItemList);
      });
    }
  }

  fetchItemId() async {
    Query itemId = FirebaseFirestore.instance
        .collection('Items')
        .doc(currentUser!.uid)
        .collection('Item')
        .orderBy("itemName");

    await itemId.get().then((docs) {
      setState(() {
        docs.docs.forEach((doc) => {itemsIdList.add(doc.id)});
      });
    });
  }

  getUser() async {
    User? firebaseUser = _auth.currentUser;
    await firebaseUser!.reload();
    firebaseUser = _auth.currentUser!;

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser!;
        this.isLoggedin = true;
      });
    }
  }

  void filterSearchResults(String query) {
    List<dynamic> dummyData = [];
    dummyData.addAll(items);
    List<QueryDocumentSnapshot> dummySearchResult = [];

    if (query.isNotEmpty) {
      dummyData.forEach((item) {
        if (item["itemName"].toLowerCase().contains(query) ||
            item["itemName"].contains(query)) {
          dummySearchResult.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummySearchResult);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(groceryItemList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('images/logo-name.png'),
        backgroundColor: new Color(0xffff),
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 90.0,
        actions: <Widget>[
          IconButton(
            color: Colors.black,
            icon: const Icon(Icons.account_circle_sharp),
            tooltip: 'Open User Profile',
            iconSize: 50,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProfilePage(currentUser)));
            },
          ),
        ],
      ),
      body: Column(children: [
        Container(
          width: 350.0,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: TextField(
            onChanged: (value) {
              filterSearchResults(value);
            },
            controller: searchController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                )),
          ),
        ),
        SingleChildScrollView(
          child: GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        )
      ]),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(MaterialPageRoute(
      //         builder: (context) => AddItem(_isEdit, "testing")));
      //   },
      //   tooltip: 'Add Grocery Item',
      //   backgroundColor: Color(0xff2C6846),
      //   child: Icon(Icons.add),
      // ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   selectedIconTheme: IconThemeData(color: Color(0xff2C6846)),
      //   selectedItemColor: Color(0xff2C6846),
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.swap_horiz),
      //       label: 'Orders',
      //     ),
      //   ],
      // ),
    );
  }
}
