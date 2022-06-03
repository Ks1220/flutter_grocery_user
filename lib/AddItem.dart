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
import 'package:geolocator/geolocator.dart';

import 'Cart.dart';

class AddItem extends StatefulWidget {
  final String _itemId;
  final String _storeId;

  const AddItem(this._itemId, this._storeId, {Key? key}) : super(key: key);

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  User? user = FirebaseAuth.instance.currentUser;
  File? _imageFile;
  late String imageUrl;
  DocumentSnapshot? groceryItem;

  int cartNumber = 0;
  double totalAmount = 0.00;
  List<double> allItemsPrice = [];
  String storeName = '';

  String dropdownvalue = 'kg';

  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _itemDescriptionController = TextEditingController();
  TextEditingController _itemStockController = TextEditingController();
  TextEditingController _itemPriceController = TextEditingController();

  bool isFavourite = false;
  @override
  void initState() {
    super.initState();
    fetchItemId();
    fetchCartInfo();
    getStoreName();
    getFavourite();
  }

  fetchCartInfo() {
    Query itemId = FirebaseFirestore.instance
        .collection('Carts')
        .doc(user!.uid)
        .collection('Item');
    itemId.get().then((docs) {
      setState(() {
        cartNumber = docs.size;

        docs.docs.forEach((doc) => {
              allItemsPrice.add(double.parse(doc["price"]) * doc["itemCount"]),
              totalAmount = allItemsPrice.sum
            });
      });
    });
  }

  fetchItemId() async {
    DocumentReference itemId = FirebaseFirestore.instance
        .collection('Items')
        .doc(widget._storeId)
        .collection('Item')
        .doc(widget._itemId);

    await itemId.get().then((docs) {
      setState(() {
        _itemNameController.text = docs["itemName"];
        _imageFile = File(docs["itemImage"]);
        imageUrl = docs["itemImage"];
        _itemDescriptionController.text = docs["itemDescription"];
        _itemStockController.text = docs["stockAmount"];
        _itemPriceController.text = docs["price"];
        dropdownvalue = docs["measurementMatrix"];
      });
    });
  }

  getStoreName() async {
    DocumentReference storeId = FirebaseFirestore.instance
        .collection('MerchantData')
        .doc(widget._storeId);
    await storeId.get().then((docs) => {
          setState(() {
            storeName = docs['storeName'];
          })
        });
  }

  setCartDetails() async {
    setState(() {
      allItemsPrice = [];
      Query itemId = FirebaseFirestore.instance
          .collection('Carts')
          .doc(user!.uid)
          .collection('Item');
      itemId.get().then((docs) {
        setState(() {
          cartNumber = docs.size;
          docs.docs.forEach((doc) => {
                allItemsPrice
                    .add(double.parse(doc["price"]) * doc["itemCount"]),
                totalAmount = allItemsPrice.sum,
              });
        });
      });
    });
  }

  getFavourite() async {
    final favExist = await FirebaseFirestore.instance
        .collection('Favourite')
        .doc(user!.uid)
        .collection('Item')
        .doc(widget._itemId)
        .get();
    if (favExist.exists) {
      isFavourite = true;
    }
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

  @override
  Widget build(BuildContext context) {
    int itemCount = 1;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65.0,
        iconTheme: IconThemeData(
          color: Color(0xff2C6846), //change your color here
        ),
        title: const Text('Product Details',
            style: TextStyle(color: Colors.black)),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: <Widget>[],
      ),
      body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Container(
          child: Column(children: [
            Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: MaterialButton(
                    onPressed: () async {
                      final snapShot = await FirebaseFirestore.instance
                          .collection('Favourite')
                          .doc(user!.uid)
                          .collection('Item')
                          .doc(widget._itemId)
                          .get();

                      if (snapShot == null || !snapShot.exists) {
                        await FirebaseFirestore.instance
                            .collection('Favourite')
                            .doc(user!.uid)
                            .collection('Item')
                            .doc(widget._itemId)
                            .set({
                          "itemName": _itemNameController.text,
                          "itemImage": imageUrl,
                          "itemDescription": _itemDescriptionController.text,
                          "price": _itemPriceController.text,
                          "measurementMatrix": dropdownvalue,
                          "storeName": storeName,
                          "id": widget._itemId,
                          "storeId": widget._storeId,
                          "stockAmount": _itemStockController.text
                        }).then((value) => {
                                  showFlash(
                                    context: context,
                                    duration: const Duration(seconds: 2),
                                    builder: (context, controller) {
                                      return Flash.bar(
                                        controller: controller,
                                        backgroundColor: Colors.green,
                                        position: FlashPosition.top,
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 70,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Added to Favourite",
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
                                  setState(
                                    () {
                                      isFavourite = true;
                                    },
                                  )
                                });
                      } else {
                        await FirebaseFirestore.instance
                            .collection('Favourite')
                            .doc(user!.uid)
                            .collection('Item')
                            .doc(widget._itemId)
                            .delete()
                            .then((value) => {
                                  showFlash(
                                    context: context,
                                    duration: const Duration(seconds: 2),
                                    builder: (context, controller) {
                                      return Flash.bar(
                                        controller: controller,
                                        backgroundColor: Colors.red,
                                        position: FlashPosition.top,
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 70,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Removed from Favourite",
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
                                  setState(() {
                                    isFavourite = false;
                                  })
                                });
                      }

                      Future.delayed(const Duration(seconds: 2), () {});
                    },
                    child: isFavourite
                        ? Icon(Icons.star, size: 35, color: Color(0xffFFCE31))
                        : Icon(Icons.star_border_outlined,
                            size: 35, color: Color(0xffFFCE31)),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        width: 140,
                        height: 140,
                        imageUrl: imageUrl,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => SizedBox(
                          width: 140,
                          height: 140,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black26,
                            ),
                          ),
                        ),
                        fit: BoxFit.fill,
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25, 25, 10, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  _itemNameController.text,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25, 10, 10, 50),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  _itemDescriptionController.text,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            Container(
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.63,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(25, 0, 0, 0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "RM${_itemPriceController.text}",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(25, 10, 0, 0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "/ $dropdownvalue",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff2C6846),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                      ),
                      minimumSize: Size(120, 50),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return SingleChildScrollView(
                                child: Container(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                                left: 20,
                                right: 20,
                                top: 10,
                              ),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CachedNetworkImage(
                                            width: 100,
                                            height: 100,
                                            imageUrl: imageUrl,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                SizedBox(
                                              width: 140,
                                              height: 140,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black26,
                                                ),
                                              ),
                                            ),
                                            fit: BoxFit.fill,
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                margin: EdgeInsets.fromLTRB(
                                                    20, 0, 0, 0),
                                                child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    "RM${_itemPriceController.text}",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                margin: EdgeInsets.fromLTRB(
                                                    20, 10, 0, 0),
                                                child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    "Stock: ${_itemStockController.text}",
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                          icon: const Icon(Icons.close),
                                          tooltip: 'Close',
                                          iconSize: 30,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 30),
                                  Wrap(children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      child: Text(
                                        "Quantity",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: FloatingActionButton(
                                        onPressed: itemCount != 1
                                            ? (() {
                                                setState(() {
                                                  itemCount -= 1;
                                                });
                                              })
                                            : null,
                                        child: Icon(Icons.remove,
                                            size: 15, color: Colors.black),
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Center(
                                      child: Text('$itemCount',
                                          style: new TextStyle(fontSize: 20.0)),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: FloatingActionButton(
                                          onPressed: itemCount <
                                                  int.parse(
                                                      _itemStockController.text)
                                              ? (() {
                                                  setState(() {
                                                    itemCount += 1;
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
                                  ]),
                                  SizedBox(height: 30),
                                  ButtonTheme(
                                    buttonColor: Color(0xff2C6846),
                                    minWidth:
                                        MediaQuery.of(context).size.width *
                                            0.92,
                                    height: 55.0,
                                    child: RaisedButton(
                                      padding:
                                          EdgeInsets.fromLTRB(70, 10, 70, 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(5.0),
                                      ),
                                      onPressed: () async {
                                        final snapShot = await FirebaseFirestore
                                            .instance
                                            .collection('Carts')
                                            .doc(user!.uid)
                                            .collection('Item')
                                            .doc(widget._itemId)
                                            .get();

                                        if (snapShot == null ||
                                            !snapShot.exists) {
                                          await FirebaseFirestore.instance
                                              .collection('Carts')
                                              .doc(user!.uid)
                                              .collection('Item')
                                              .doc(widget._itemId)
                                              .set({
                                            "itemName":
                                                _itemNameController.text,
                                            "itemImage": imageUrl,
                                            "itemDescription":
                                                _itemDescriptionController.text,
                                            "price": _itemPriceController.text,
                                            "measurementMatrix": dropdownvalue,
                                            "itemCount": itemCount,
                                            "storeName": storeName,
                                            "id": widget._itemId,
                                            "storeId": widget._storeId,
                                            "stockAmount":
                                                _itemStockController.text
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
                                                    setState(() {
                                                      allItemsPrice = [];
                                                      Query itemId =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'Carts')
                                                              .doc(user!.uid)
                                                              .collection(
                                                                  'Item');
                                                      itemId.get().then((docs) {
                                                        setState(() {
                                                          cartNumber =
                                                              docs.size;

                                                          docs.docs
                                                              .forEach(
                                                                  (doc) => {
                                                                        allItemsPrice.add(double.parse(doc["price"]) *
                                                                            doc["itemCount"]),
                                                                        totalAmount =
                                                                            allItemsPrice.sum,
                                                                      });
                                                        });
                                                      });
                                                    }),
                                                    Navigator.pop(context)
                                                  });
                                        } else {
                                          await FirebaseFirestore.instance
                                              .collection('Carts')
                                              .doc(user!.uid)
                                              .collection('Item')
                                              .doc(widget._itemId)
                                              .update({
                                            "itemCount":
                                                FieldValue.increment(itemCount)
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
                                                    setCartDetails(),
                                                    Navigator.pop(context)
                                                  });
                                        }
                                        Future.delayed(
                                            const Duration(seconds: 2), () {});
                                      },
                                      child: Text('Add to Cart',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  )
                                ],
                              ),
                            ));
                          });
                        },
                      );
                    },
                    child: Text('Add to Cart'),
                  )),
                ],
              ),
            ),
            Expanded(
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width * 0.92,
                      buttonColor: Color(0xff2C6846),
                      height: 55.0,
                      child: RaisedButton(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(5.0),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Cart()));
                        },
                        child: Wrap(
                          spacing: 100,
                          runSpacing: 100,
                          children: [
                            Text('Cart . $cartNumber Item',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600)),
                            Text('RM${totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600))
                          ],
                        ),
                      ),
                    ),
                  )),
            )
          ]),
        );
      }),
    );
  }
}
