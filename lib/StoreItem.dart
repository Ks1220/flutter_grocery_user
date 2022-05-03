import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
import 'package:flutter/material.dart';

import 'AddItem.dart';
import 'databaseManager/DatabaseManager.dart';

class StoreItem extends StatefulWidget {
  final String _storeId;
  const StoreItem(this._storeId, {Key? key}) : super(key: key);

  @override
  _StoreItemState createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {
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

  String storeName = "", storeAddress = "", shopLogo = "";

  @override
  void initState() {
    super.initState();
    fetchGroceryItemList();
    fetchItemId();
    fetchShopDetails();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  fetchGroceryItemList() async {
    dynamic resultant = await DatabaseManager().getGroceryList(widget._storeId);
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
        .doc(widget._storeId)
        .collection('Item')
        .orderBy("itemName");

    await itemId.get().then((docs) {
      setState(() {
        docs.docs.forEach((doc) => {itemsIdList.add(doc.id)});
      });
    });
  }

  fetchShopDetails() async {
    DocumentReference shopDetails = FirebaseFirestore.instance
        .collection('MerchantData')
        .doc(widget._storeId);

    await shopDetails.get().then((docs) {
      setState(() {
        storeName = docs["storeName"];
        storeAddress = docs["storeAddress"];
        shopLogo = docs["shopLogo"];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65.0,
        iconTheme: IconThemeData(
          color: Color(0xff2C6846), //change your color here
        ),
        title: const Text('Shop', style: TextStyle(color: Colors.black)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(children: [
        Container(
          width: 380,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black38),
            borderRadius: BorderRadius.circular(5),
            boxShadow: kElevationToShadow[4],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
            child: Row(
              children: [
                Center(
                    child: Padding(
                  padding: EdgeInsets.all(0),
                  child: CachedNetworkImage(
                    width: 60,
                    height: 60,
                    imageUrl: shopLogo,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => SizedBox(
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                        ),
                      ),
                    ),
                    fit: BoxFit.fill,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                )),
                VerticalDivider(
                  color: Colors.grey,
                  thickness: 2,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: RichText(
                          text: TextSpan(
                            text: storeName,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.65,
                      ),
                      Container(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: storeAddress,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          width: 383.0,
          margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
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
        items.length == 0 && searchController.text.isEmpty
            ? Container(
                height: MediaQuery.of(context).size.width,
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                          width: 100,
                          height: 100,
                          image: AssetImage("images/empty-guide.png"),
                          fit: BoxFit.contain),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          width: 200,
                          child: Text(
                            "This merchant has not uploaded any items yet. STAY TUNE!",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 17,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ))
                    ],
                  ),
                ),
              )
            : Expanded(
                child: searchController.text.length > 0
                    ? ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (ctx, index) {
                          return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AddItem(_isEdit,
                                        itemsIdList[index], widget._storeId)));
                              },
                              child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 15.0, 30, 0.0),
                                  height: 90,
                                  child: ListTile(
                                    shape: Border(
                                        bottom: BorderSide(
                                            color: Color.fromARGB(
                                                255, 199, 199, 199),
                                            width: 1)),
                                    title: Text(items.length > 0
                                        ? "${items[index]["itemName"]}"
                                        : ""),
                                    subtitle: Text(items.length > 0
                                        ? "RM ${items[index]["price"]}/${items[index]["measurementMatrix"]}"
                                        : ""),
                                    leading: (CachedNetworkImage(
                                      width: 65,
                                      height: 65,
                                      imageUrl: items[index]["itemImage"],
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              SizedBox(
                                        width: 65,
                                        height: 65,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black26,
                                          ),
                                        ),
                                      ),
                                      fit: BoxFit.fill,
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )),
                                    trailing: Text(items.length > 0
                                        ? "Stock: ${items[index]["stockAmount"]}"
                                        : ""),
                                  )));
                        },
                      )
                    : AlphabetScrollView(
                        list: nameList.map((e) => AlphaModel(e)).toList(),
                        alignment: LetterAlignment.right,
                        itemExtent: 150,
                        unselectedTextStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                        selectedTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2C6846)),
                        overlayWidget: (value) => Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              size: 50,
                              color: Colors.red,
                            ),
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$value'.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        itemBuilder: (_, index, buildContext) {
                          return (GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AddItem(_isEdit,
                                        itemsIdList[index], widget._storeId)));
                              },
                              child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 15.0, 30, 0.0),
                                  height: 90,
                                  child: ListTile(
                                    shape: Border(
                                        bottom: BorderSide(
                                            color: Color.fromARGB(
                                                255, 199, 199, 199),
                                            width: 1)),
                                    title: Text(items.length > 0
                                        ? "${items[index]["itemName"]}"
                                        : ""),
                                    subtitle: Text(items.length > 0
                                        ? "RM ${items[index]["price"]}/${items[index]["measurementMatrix"]}"
                                        : ""),
                                    leading: (CachedNetworkImage(
                                      width: 65,
                                      height: 65,
                                      imageUrl: items[index]["itemImage"],
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              SizedBox(
                                        width: 65,
                                        height: 65,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black26,
                                          ),
                                        ),
                                      ),
                                      fit: BoxFit.fill,
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )),
                                    trailing: Text(items.length > 0
                                        ? "Stock: ${items[index]["stockAmount"]}"
                                        : ""),
                                  ))));
                        },
                      )),
      ]),
    );
  }
}
