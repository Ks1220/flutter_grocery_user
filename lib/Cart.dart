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
                          ),
                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.of(context).pop();
                          })
                        });
              },
            ),
          ],
        );
      },
    );
  }

  showError(BuildContext context, Object errormessage) {
    showFlash(
      context: context,
      duration: const Duration(seconds: 5),
      builder: (context, controller) {
        return Flash.bar(
          controller: controller,
          backgroundColor: Colors.red,
          position: FlashPosition.top,
          child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 70,
              child: Text(
                errormessage.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              )),
        );
      },
    );
  }

  fetchGroceryItemList() async {
    dynamic resultant = await DatabaseManager().getCartList(user!.uid);
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
          : Container(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, index) {
                  return Container(
                      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 15.0, 0.0),
                      height: 120,
                      child: ListTile(
                          shape: Border(
                              bottom: BorderSide(
                                  color: Color.fromARGB(255, 199, 199, 199),
                                  width: 1)),
                          title: Text(
                            items.length > 0
                                ? "${items[index]["itemName"]}"
                                : "",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: SizedBox(height: 20),
                                ),
                                TextSpan(
                                    style: TextStyle(color: Colors.black),
                                    text:
                                        "RM ${items[index]["price"]}/${items[index]["measurementMatrix"]} \n"),
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
                                      " ${items[index]["storeName"]}",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          leading: (CachedNetworkImage(
                            width: 65,
                            height: 120,
                            imageUrl: items[index]["itemImage"],
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => SizedBox(
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
                          trailing: Transform.translate(
                            offset: const Offset(0.0, 5.0),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              alignment: WrapAlignment.spaceEvenly,
                              children: <Widget>[
                                SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Visibility(
                                      visible: items[index]['itemCount'] != 1
                                          ? true
                                          : false,
                                      child: FloatingActionButton(
                                        onPressed: (() async {
                                          await FirebaseFirestore.instance
                                              .collection('Carts')
                                              .doc(user!.uid)
                                              .collection('Item')
                                              .doc(items[index]['id'])
                                              .update({
                                            "itemCount":
                                                FieldValue.increment(-1)
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
                                                              Colors.red,
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
                                                                    "Remove Successfully",
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
                                                    // setState(() {
                                                    //   allItemsPrice = [];
                                                    //   Query itemId = FirebaseFirestore.instance
                                                    //       .collection('Carts')
                                                    //       .doc(user!.uid)
                                                    //       .collection('Item');
                                                    //   itemId.get().then((docs) {
                                                    //     setState(() {
                                                    //       cartNumber = docs.size;

                                                    //       docs.docs.forEach((doc) => {
                                                    //             allItemsPrice.add(
                                                    //                 double.parse(doc["price"]) *
                                                    //                     doc["itemCount"]),
                                                    //             totalAmount = allItemsPrice.sum,
                                                    //           });
                                                    //     });
                                                    //   });
                                                    // })
                                                  });
                                        }),
                                        child: Icon(Icons.remove,
                                            size: 15, color: Colors.black),
                                        backgroundColor: Colors.white,
                                      )),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('${items[index]["itemCount"]}',
                                    style: new TextStyle(fontSize: 25.0)),
                                SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: FloatingActionButton(
                                      onPressed: (() async {
                                        await FirebaseFirestore.instance
                                            .collection('Carts')
                                            .doc(user!.uid)
                                            .collection('Item')
                                            .doc(items[index]['id'])
                                            .update({
                                          "itemCount": FieldValue.increment(1)
                                        }).then((value) => {
                                                  showFlash(
                                                    context: context,
                                                    duration: const Duration(
                                                        seconds: 2),
                                                    builder:
                                                        (context, controller) {
                                                      return Flash.bar(
                                                        controller: controller,
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
                                                                  "Added Successfully",
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
                                                  // setState(() {
                                                  //   allItemsPrice = [];
                                                  //   Query itemId = FirebaseFirestore.instance
                                                  //       .collection('Carts')
                                                  //       .doc(user!.uid)
                                                  //       .collection('Item');
                                                  //   itemId.get().then((docs) {
                                                  //     setState(() {
                                                  //       cartNumber = docs.size;

                                                  //       docs.docs.forEach((doc) => {
                                                  //             allItemsPrice.add(
                                                  //                 double.parse(doc["price"]) *
                                                  //                     doc["itemCount"]),
                                                  //             totalAmount = allItemsPrice.sum,
                                                  //           });
                                                  //     });
                                                  //   });
                                                  // })
                                                });
                                      }),
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
                                ElevatedButton(
                                  onPressed: (() {
                                    showDeleteItemsDialog(items[index]['id']);
                                  }),
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xff2C6846),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(5.0),
                                    ),
                                    minimumSize: Size(30, 45),
                                  ),
                                ),
                              ],
                            ),
                          )));
                },
              ),
            ),
    );
  }
}
