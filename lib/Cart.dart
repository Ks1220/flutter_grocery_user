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

import 'AddItem.dart';
import 'databaseManager/DatabaseManager.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
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
                Text('Are you sure to remove this item from your cart?'),
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
                    .collection('Carts')
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
        .collection('Carts')
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
        title: const Text('My Cart', style: TextStyle(color: Colors.black)),
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
                          "Your cart is empty",
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
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: DatabaseManager().getCartList(user!.uid),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (ctx, index) {
                              return Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 15.0, 15.0, 0.0),
                                  height: 120,
                                  child: ListTile(
                                      shape: Border(
                                          bottom: BorderSide(
                                              color: Color.fromARGB(
                                                  255, 199, 199, 199),
                                              width: 1)),
                                      title: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) => AddItem(
                                                      snapshot.data!.docs[index]
                                                          ["id"],
                                                      snapshot.data!.docs[index]
                                                          ["storeId"])));
                                        },
                                        child: Text(
                                          "${snapshot.data!.docs[index]["itemName"]}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      subtitle: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) => AddItem(
                                                      snapshot.data!.docs[index]
                                                          ["id"],
                                                      snapshot.data!.docs[index]
                                                          ["storeId"])));
                                        },
                                        child: RichText(
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
                                                  offset:
                                                      const Offset(0.0, -3.0),
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
                                      ),
                                      leading: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) => AddItem(
                                                      snapshot.data!.docs[index]
                                                          ["id"],
                                                      snapshot.data!.docs[index]
                                                          ["storeId"])));
                                        },
                                        child: (CachedNetworkImage(
                                          width: 65,
                                          height: 120,
                                          imageUrl: snapshot.data!.docs[index]
                                              ["itemImage"],
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
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
                                      ),
                                      trailing: Transform.translate(
                                        offset: const Offset(0.0, 10.0),
                                        child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          alignment: WrapAlignment.spaceEvenly,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 25,
                                              width: 25,
                                              child: FloatingActionButton(
                                                onPressed: snapshot.data!
                                                                .docs[index]
                                                            ['itemCount'] !=
                                                        1
                                                    ? (() async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('Carts')
                                                            .doc(user!.uid)
                                                            .collection('Item')
                                                            .doc(snapshot.data!
                                                                    .docs[index]
                                                                ['id'])
                                                            .update({
                                                          "itemCount":
                                                              FieldValue
                                                                  .increment(-1)
                                                        }).then((value) => {
                                                                  showFlash(
                                                                    context:
                                                                        context,
                                                                    duration: const Duration(
                                                                        seconds:
                                                                            2),
                                                                    builder:
                                                                        (context,
                                                                            controller) {
                                                                      return Flash
                                                                          .bar(
                                                                        controller:
                                                                            controller,
                                                                        backgroundColor:
                                                                            Colors.red,
                                                                        position:
                                                                            FlashPosition.top,
                                                                        child: Container(
                                                                            width: MediaQuery.of(context).size.width,
                                                                            height: 70,
                                                                            child: Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  "Removed from Cart",
                                                                                  style: const TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontSize: 18,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            )),
                                                                      );
                                                                    },
                                                                  ),
                                                                });
                                                      })
                                                    : null,
                                                child: Icon(Icons.remove,
                                                    size: 15,
                                                    color: Colors.black),
                                                backgroundColor: Colors.white,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                                '${snapshot.data!.docs[index]["itemCount"]}',
                                                style: new TextStyle(
                                                    fontSize: 20.0)),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: FloatingActionButton(
                                                  onPressed: snapshot.data!
                                                                  .docs[index]
                                                              ['itemCount'] <
                                                          int.parse(snapshot
                                                                  .data!
                                                                  .docs[index]
                                                              ["stockAmount"])
                                                      ? (() async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'Carts')
                                                              .doc(user!.uid)
                                                              .collection(
                                                                  'Item')
                                                              .doc(snapshot
                                                                      .data!
                                                                      .docs[
                                                                  index]['id'])
                                                              .update({
                                                            "itemCount":
                                                                FieldValue
                                                                    .increment(
                                                                        1)
                                                          }).then((value) => {
                                                                    showFlash(
                                                                      context:
                                                                          context,
                                                                      duration: const Duration(
                                                                          seconds:
                                                                              2),
                                                                      builder:
                                                                          (context,
                                                                              controller) {
                                                                        return Flash
                                                                            .bar(
                                                                          controller:
                                                                              controller,
                                                                          backgroundColor:
                                                                              Colors.green,
                                                                          position:
                                                                              FlashPosition.top,
                                                                          child: Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              height: 70,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Text(
                                                                                    "Added to Cart Successfully",
                                                                                    style: const TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 18,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )),
                                                                        );
                                                                      },
                                                                    ),
                                                                  });
                                                        })
                                                      : null,
                                                  child: new Icon(
                                                    Icons.add,
                                                    size: 15,
                                                    color: Colors.black,
                                                  ),
                                                  backgroundColor: Colors.white,
                                                )),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            SizedBox.fromSize(
                                              size: Size(30, 30),
                                              child: Material(
                                                color: Color(0xff2C6846),
                                                child: InkWell(
                                                  splashColor: Colors.green,
                                                  onTap: () {
                                                    showDeleteItemsDialog(
                                                        snapshot.data!
                                                            .docs[index]['id']);
                                                  }, // button pressed
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.clear,
                                                        size: 18,
                                                        color: Colors.white,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )));
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text('no data');
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      color: Colors.white,
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: ButtonTheme(
                                buttonColor: Colors.white,
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.9,
                                height: 55.0,
                                child: RaisedButton(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Color(0xff2C6846), width: 2),
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                  ),
                                  onPressed: () {
                                    // showLogOutDialog();
                                  },
                                  child: Text('Self Pick-Up',
                                      style: TextStyle(
                                          color: Color(0xff2C6846),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: ButtonTheme(
                                buttonColor: Color(0xff2C6846),
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.3,
                                height: 55.0,
                                child: RaisedButton(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                  ),
                                  onPressed: () {
                                    // showLogOutDialog();
                                  },
                                  child: Text('Buy Now',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
