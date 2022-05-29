import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'AddItem.dart';
import 'databaseManager/DatabaseManager.dart';

class Favourite extends StatefulWidget {
  const Favourite({Key? key}) : super(key: key);

  @override
  _FavouriteState createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  User? user = FirebaseAuth.instance.currentUser;
  List storeId = [];

  List groceryItemList = [];
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchGroceryItemList();
  }

  showDeleteItemsDialog(itemId) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Image'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                    'Are you sure to remove this item from your favourite list?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Ok',
                style: TextStyle(color: Color(0xff2C6846)),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('Favourite')
                    .doc(user!.uid)
                    .collection('Item')
                    .doc(itemId)
                    .delete()
                    .then((value) => {
                          Navigator.of(context).pop(),
                          showFlash(
                            context: context,
                            duration: const Duration(seconds: 2),
                            builder: (context, controller) {
                              return Flash.bar(
                                controller: controller,
                                backgroundColor: Colors.green,
                                position: FlashPosition.top,
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 70,
                                    child: Center(
                                      child: Text(
                                        "Removed Successfully",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    )),
                              );
                            },
                          )
                        });
              },
            ),
          ],
        );
      },
    );
  }

  fetchGroceryItemList() async {
    Query query = FirebaseFirestore.instance
        .collection('Favourite')
        .doc(user!.uid)
        .collection('Item')
        .orderBy("storeName");
    List itemsList = [];
    await query.get().then((docs) {
      docs.docs.forEach((doc) {
        itemsList.add(doc);
      });
    });

    dynamic resultant = itemsList;

    if (resultant == null) {
      print("Unable to retrieve");
    } else {
      setState(() {
        groceryItemList = resultant;
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
        title:
            const Text('My Favourite', style: TextStyle(color: Colors.black)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: items.length == 0
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
                        width: 170,
                        child: Text(
                          "No Favourite",
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
          : Container(
              child: StreamBuilder(
                  stream: DatabaseManager().getFavouriteList(user!.uid),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (ctx, index) {
                          return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AddItem(
                                        snapshot.data!.docs[index]["id"],
                                        snapshot.data!.docs[index]
                                            ["storeId"])));
                              },
                              child: Slidable(
                                key: UniqueKey(),
                                startActionPane: ActionPane(
                                  motion: const StretchMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (ctx) {
                                        showDeleteItemsDialog(
                                            snapshot.data!.docs[index]['id']);
                                      },
                                      backgroundColor: Color(0xFFFE4A49),
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                    SlidableAction(
                                      onPressed: (ctx) {},
                                      backgroundColor: Color(0xFF21B7CA),
                                      foregroundColor: Colors.white,
                                      icon: Icons.share,
                                      label: 'Share',
                                    ),
                                  ],
                                ),
                                endActionPane: ActionPane(
                                  motion: const StretchMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (ctx) {
                                        showDeleteItemsDialog(
                                            snapshot.data!.docs[index]['id']);
                                      },
                                      backgroundColor: Color(0xFFFE4A49),
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                    SlidableAction(
                                      onPressed: (ctx) {},
                                      backgroundColor: Color(0xFF21B7CA),
                                      foregroundColor: Colors.white,
                                      icon: Icons.share,
                                      label: 'Share',
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
                                  child: ListTile(
                                    title: Text(
                                      "${snapshot.data!.docs[index]["itemName"]}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                    subtitle: RichText(
                                      text: TextSpan(
                                        children: [
                                          WidgetSpan(
                                            child: SizedBox(height: 20),
                                          ),
                                          TextSpan(
                                              style: TextStyle(
                                                  color: Colors.black),
                                              text:
                                                  "RM ${snapshot.data!.docs[index]["price"]}/${snapshot.data!.docs[index]["measurementMatrix"]} \n"),
                                          WidgetSpan(
                                            child: SizedBox(height: 35),
                                          ),
                                          WidgetSpan(
                                            child: Icon(
                                              Icons.store,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          WidgetSpan(
                                            child: Transform.translate(
                                              offset: const Offset(0.0, -3.0),
                                              child: Text(
                                                " ${snapshot.data!.docs[index]["storeName"]}",
                                                style: TextStyle(
                                                    color: Colors.black54),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    leading: (CachedNetworkImage(
                                      width: 65,
                                      height: 120,
                                      imageUrl: snapshot.data!.docs[index]
                                          ["itemImage"],
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              SizedBox(
                                        width: 65,
                                        height: 120,
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
                                    trailing: Container(
                                        child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Color(0xff2C6846),
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(5.0),
                                        ),
                                        minimumSize: Size(100, 40),
                                      ),
                                      onPressed: () async {
                                        final snapShot = await FirebaseFirestore
                                            .instance
                                            .collection('Carts')
                                            .doc(user!.uid)
                                            .collection('Item')
                                            .doc(snapshot.data!.docs[index]
                                                ["id"])
                                            .get();

                                        if (snapShot == null ||
                                            !snapShot.exists) {
                                          await FirebaseFirestore.instance
                                              .collection('Carts')
                                              .doc(user!.uid)
                                              .collection('Item')
                                              .doc(snapshot.data!.docs[index]
                                                  ["id"])
                                              .set({
                                            "itemName": snapshot
                                                .data!.docs[index]["itemName"],
                                            "itemImage": snapshot
                                                .data!.docs[index]["itemImage"],
                                            "itemDescription": snapshot.data!
                                                .docs[index]["itemDescription"],
                                            "price": snapshot.data!.docs[index]
                                                ["price"],
                                            "measurementMatrix":
                                                snapshot.data!.docs[index]
                                                    ["measurementMatrix"],
                                            "itemCount": 1,
                                            "storeId": snapshot
                                                .data!.docs[index]["storeId"],
                                            "storeName": snapshot
                                                .data!.docs[index]["storeName"],
                                            "id": snapshot.data!.docs[index]
                                                ["id"]
                                          }).then((value) => {
                                                    showFlash(
                                                      context: context,
                                                      duration: const Duration(
                                                          seconds: 2),
                                                      builder: (context,
                                                          controller) {
                                                        return Flash.bar(
                                                          controller:
                                                              controller,
                                                          backgroundColor:
                                                              Colors.green,
                                                          position:
                                                              FlashPosition.top,
                                                          child: Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              height: 70,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    "Added to Cart Successfully",
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )),
                                                        );
                                                      },
                                                    ),
                                                  });
                                        } else {
                                          await FirebaseFirestore.instance
                                              .collection('Carts')
                                              .doc(user!.uid)
                                              .collection('Item')
                                              .doc(snapshot.data!.docs[index]
                                                  ["id"])
                                              .update({
                                            "itemCount": FieldValue.increment(1)
                                          }).then((value) => {
                                                    showFlash(
                                                      context: context,
                                                      duration: const Duration(
                                                          seconds: 2),
                                                      builder: (context,
                                                          controller) {
                                                        return Flash.bar(
                                                          controller:
                                                              controller,
                                                          backgroundColor:
                                                              Colors.green,
                                                          position:
                                                              FlashPosition.top,
                                                          child: Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              height: 70,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    "Added to Cart Successfully",
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          18,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )),
                                                        );
                                                      },
                                                    ),
                                                  });
                                        }

                                        Future.delayed(
                                            const Duration(seconds: 2), () {});
                                      },
                                      child: Text('Add to Cart'),
                                    )),
                                  ),
                                ),
                              ));
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('no data');
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
    );
  }
}
