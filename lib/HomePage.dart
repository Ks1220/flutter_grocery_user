import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery_user/ProfilePage.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:clippy_flutter/triangle.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'StoreItem.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User user;
  User? currentUser = FirebaseAuth.instance.currentUser;
  TextEditingController searchController = TextEditingController();

  bool isLoggedin = true;

  List groceryItemList = [];
  List nameList = [];
  List itemsIdList = [];
  List items = [];

  Set<Marker> _markers = {};
  late BitmapDescriptor mapMarker;
  Completer<GoogleMapController> _controller = Completer();

  Position? _currentPosition;
  String? _currentAddress;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  String? name;

  int _selectedIndex = 0;

  var mapData = [];

  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('MerchantData');

  void setCustomMarker() async {
    mapMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'images/marker.png');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchItemId();
    searchController = TextEditingController();
    _getCurrentLocation();
    getMerchantData();
    setCustomMarker();
    testing();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _customInfoWindowController.dispose();
  }

  void testing() {}

  void _onMapCreated(GoogleMapController controller) {
    // ignore: unnecessary_statements

    setState(() {
      _customInfoWindowController.googleMapController = controller;
      mapData.forEach((items) {
        _markers.add(Marker(
          markerId: MarkerId(items['uid']),
          position: LatLng(items['latitude'], items['longitude']),
          icon: mapMarker,
          onTap: () {
            _customInfoWindowController.addInfoWindow!(
              Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            Center(
                                child: Padding(
                              padding: EdgeInsets.all(7),
                              child: CachedNetworkImage(
                                width: 80,
                                height: 80,
                                imageUrl: items["shopLogo"],
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                    ),
                                  ),
                                ),
                                fit: BoxFit.fill,
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            )),
                            VerticalDivider(
                              color: Colors.grey,
                              thickness: 2,
                            ),
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 5, bottom: 15, top: 15),
                                  child: RichText(
                                    text: TextSpan(
                                      text: items["storeName"],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: items["storeAddress"],
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        StoreItem(items["uid"])));
                              },
                              child: AbsorbPointer(
                                  child: Center(
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(Icons.chevron_right_outlined),
                                  color: Colors.black87,
                                  iconSize: 45.0,
                                  onPressed: () => {},
                                ),
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Triangle.isosceles(
                    edge: Edge.BOTTOM,
                    child: Container(
                      color: Colors.white,
                      width: 20.0,
                      height: 10.0,
                    ),
                  ),
                ],
              ),
              LatLng(items['latitude'], items['longitude']),
            );
          },
        ));
      });
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);
      Placemark place = p[0];
      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
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

  Future<List> getMerchantData() async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    mapData = allData;
    return mapData;
  }

  @override
  Widget build(BuildContext context) {
    final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      ),
      zoom: 17,
    );

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('images/logo-name.png'),
        backgroundColor: new Color(0xffff),
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 90.0,
        actions: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              color: Colors.black,
              icon: const Icon(Icons.account_circle_sharp),
              tooltip: 'Open User Profile',
              iconSize: 45,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfilePage(currentUser)));
              },
            ),
          )
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
        Expanded(
          child: Stack(children: [
            GoogleMap(
              onTap: (position) {
                _customInfoWindowController.hideInfoWindow!();
              },
              onCameraMove: (CameraPosition cameraPositiona) {
                _customInfoWindowController.hideInfoWindow!();
              },
              mapType: MapType.hybrid,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: _onMapCreated,
              markers: _markers,
            ),
            CustomInfoWindow(
              controller: _customInfoWindowController,
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ]),
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedIconTheme: IconThemeData(color: Color(0xff2C6846)),
        selectedItemColor: Color(0xff2C6846),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favourite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'My Orders',
          ),
        ],
      ),
    );
  }
}
