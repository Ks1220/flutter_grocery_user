import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:collection/collection.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'AddItem.dart';
import 'Start.dart';
import 'ThankYou.dart';
import 'databaseManager/DatabaseManager.dart';

class CheckoutSelfPickUp extends StatefulWidget {
  const CheckoutSelfPickUp({Key? key}) : super(key: key);

  @override
  _CheckoutSelfPickUpState createState() => _CheckoutSelfPickUpState();
}

class _CheckoutSelfPickUpState extends State<CheckoutSelfPickUp> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    getData();
    setCartDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _storeNameController = TextEditingController();
  TextEditingController _shippingAddressController = TextEditingController();

  File? _imageFile;
  late String imageUrl;

  int cartNumber = 0;
  double totalAmount = 0.00;
  List<double> allItemsPrice = [];
  List<String> allAddress = [];

  var length;

  fetchCartInfo() {
    Query itemId = FirebaseFirestore.instance
        .collection('Carts')
        .doc(currentUser!.uid)
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

  fetchAddress() {
    Query itemId = FirebaseFirestore.instance
        .collection('Carts')
        .doc(currentUser!.uid)
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

  setCartDetails() async {
    setState(() {
      allItemsPrice = [];
      Query itemId = FirebaseFirestore.instance
          .collection('Carts')
          .doc(currentUser!.uid)
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

  getData() async {
    var firestore = FirebaseFirestore.instance;
    DocumentSnapshot qn =
        await firestore.collection('UserData').doc(currentUser?.uid).get();

    return qn.data();
  }

  copy() async {
    QuerySnapshot snaphsot = await FirebaseFirestore.instance
        .collection('Carts')
        .doc(currentUser!.uid)
        .collection('Item')
        .get();

    for (var message in snaphsot.docs) {
      FirebaseFirestore.instance
          .collection('UserOrders')
          .doc(currentUser!.uid)
          .collection('Item')
          .doc(message.data()["id"])
          .set({
        "itemName": message.data()["itemName"],
        "type": "SelfPickUp",
        "itemImage": message.data()["itemImage"],
        "itemDescription": message.data()["itemDescription"],
        "price": message.data()["price"],
        "measurementMatrix": message.data()["measurementMatrix"],
        "itemCount": message.data()["itemCount"],
        "storeId": message.data()["storeId"],
        "storeName": message.data()["storeName"],
        "id": message.data()["id"],
        "stockAmount": message.data()["stockAmount"],
      }).then((value) => {
                FirebaseFirestore.instance
                    .collection('MerchantOrders')
                    .doc(message.data()["storeId"])
                    .collection('User')
                    .doc(currentUser!.uid)
                    .collection('Item')
                    .doc(message.data()["id"])
                    .set({
                  "userId": currentUser!.uid,
                  "type": "SelfPickUp",
                  "itemName": message.data()["itemName"],
                  "itemImage": message.data()["itemImage"],
                  "itemDescription": message.data()["itemDescription"],
                  "price": message.data()["price"],
                  "measurementMatrix": message.data()["measurementMatrix"],
                  "itemCount": message.data()["itemCount"],
                  "storeId": message.data()["storeId"],
                  "storeName": message.data()["storeName"],
                  "id": message.data()["id"],
                  "stockAmount": message.data()["stockAmount"],
                })
              });
    }
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Ordered Successfully",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              )),
        );
      },
    ).then((value) => Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ThankYou())));
  }

  @override
  Widget build(BuildContext context) {
    print("ALL ADDRESS: $allAddress");
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 65.0,
          iconTheme: IconThemeData(
            color: Color(0xff2C6846), //change your color here
          ),
          title: const Text('Checkout', style: TextStyle(color: Colors.black)),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Stack(fit: StackFit.expand, children: [
          SingleChildScrollView(
            child: FutureBuilder(
              future: getData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                _nameController.text =
                    (snapshot.data as Map<String, dynamic>)['name'];

                _shippingAddressController.text =
                    (snapshot.data as Map<String, dynamic>)['shippingAddress'];
                imageUrl = (snapshot.data as Map<String, dynamic>)['shopLogo'];

                if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return Column(children: [
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(left: 10, top: 5),
                            child: Text(
                              "Order Summary",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      StreamBuilder(
                          stream:
                              DatabaseManager().getCartList(currentUser!.uid),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                separatorBuilder: (_, __) => Container(
                                    height: 2.0, color: Colors.grey[300]),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (ctx, index) {
                                  return Container(
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
                                                child: SizedBox(height: 30),
                                              ),
                                              WidgetSpan(
                                                child: Text(
                                                  "RM",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              WidgetSpan(
                                                child: Transform.translate(
                                                  offset:
                                                      const Offset(0.0, 0.0),
                                                  child: Text(
                                                    "${snapshot.data!.docs[index]["price"]}",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              TextSpan(
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  text:
                                                      "RM ${snapshot.data!.docs[index]["price"]}/${snapshot.data!.docs[index]["measurementMatrix"]} \n"),
                                              WidgetSpan(
                                                child: SizedBox(height: 40),
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
                                        leading: CachedNetworkImage(
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
                                        ),
                                        trailing: Transform.translate(
                                          offset: const Offset(0.0, 20.0),
                                          child: Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            alignment:
                                                WrapAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Text(
                                                  'x ${snapshot.data!.docs[index]["itemCount"]}',
                                                  style: new TextStyle(
                                                      fontSize: 16.0)),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                        )),
                                  );
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Text('no data');
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Text(
                            "** Please be aware that you have selected self-pick up, address is provided in the shop page.",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500)),
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(left: 10, top: 5),
                            child: Text(
                              "Payment Summary",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                        child: ListTile(
                          title: Text(
                            "Merchandise Subtotal",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          trailing: Text(
                            "RM${totalAmount.toStringAsFixed(2)}",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                        child: ListTile(
                          title: Text(
                            "Shipping Subtotal",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          trailing: Text(
                            "RM6.00",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                        child: ListTile(
                          title: Text(
                            "Total Payment",
                            style: TextStyle(fontSize: 16),
                          ),
                          trailing: Text(
                            "RM${(totalAmount + 6).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff2C6846),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 100)
                    ]);
                  }
                } else if (snapshot.hasError) {
                  return Text('no data');
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Positioned(
            right: 0.0,
            bottom: 0.0,
            child: Row(
              children: [
                Container(
                  color: Color.fromARGB(255, 235, 235, 235),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                                padding: EdgeInsets.only(top: 10, right: 10),
                                child: Text("Total Payment",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black54))),
                            Container(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  "RM${(totalAmount + 6).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xff2C6846),
                                  ),
                                )),
                          ]),
                      ButtonTheme(
                        buttonColor: Color(0xff2C6846),
                        minWidth: MediaQuery.of(context).size.width * 0.3,
                        height: 60.0,
                        child: RaisedButton(
                          padding: EdgeInsets.fromLTRB(30, 25, 30, 25),
                          onPressed: () {
                            copy();
                          },
                          child: Text('Place Order',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]));
  }
}
