import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'AddItem.dart';
import 'Start.dart';
import 'databaseManager/DatabaseManager.dart';

class Checkout extends StatefulWidget {
  const Checkout({Key? key}) : super(key: key);

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout>
    with AutomaticKeepAliveClientMixin<Checkout> {
  @override
  bool get wantKeepAlive => true;
  late final Future? myFuture;

  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    getData();
    getCartLength();
    myFuture = getData();
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

  var length;

  getData() async {
    var firestore = FirebaseFirestore.instance;
    DocumentSnapshot qn =
        await firestore.collection('UserData').doc(currentUser?.uid).get();

    return qn.data();
  }

  getCartLength() async {
    dynamic resultant = await DatabaseManager().getCartLength(currentUser!.uid);
    length = resultant;

    return resultant;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    dynamic resultant = DatabaseManager().getCartLength(currentUser!.uid);

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
        body: Stack(children: [
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
              child: FutureBuilder(
                future: getData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  _nameController.text =
                      (snapshot.data as Map<String, dynamic>)['name'];

                  _shippingAddressController.text = (snapshot.data
                      as Map<String, dynamic>)['shippingAddress'];
                  imageUrl =
                      (snapshot.data as Map<String, dynamic>)['shopLogo'];

                  if (snapshot.hasData) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return Column(children: [
                        ListTile(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return SingleChildScrollView(
                                      child: Container(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom,
                                      left: 20,
                                      right: 20,
                                      top: 10,
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Text(
                                              'Shipping Address',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              tooltip: 'Close',
                                              iconSize: 30,
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Form(
                                          key: _formKey,
                                          child: TextFormField(
                                            controller:
                                                _shippingAddressController,
                                            validator: (input) {
                                              if (input!.isEmpty)
                                                return 'Please enter Shipping Address';
                                            },
                                            maxLines: 4,
                                            decoration: InputDecoration(
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red),
                                                ),
                                                errorStyle:
                                                    TextStyle(height: 0.4),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20.0),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.grey)),
                                                focusColor: Colors.grey,
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                  color: Colors.grey,
                                                )),
                                                labelText:
                                                    "Enter Shipping Address",
                                                labelStyle: TextStyle(
                                                    color: Colors.grey),
                                                prefixIcon: Icon(
                                                    Icons.location_on_outlined,
                                                    color: Colors.grey)),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        ButtonTheme(
                                          buttonColor: Color(0xff2C6846),
                                          minWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.92,
                                          height: 55.0,
                                          child: RaisedButton(
                                            padding: EdgeInsets.fromLTRB(
                                                70, 10, 70, 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      5.0),
                                            ),
                                            onPressed: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                await FirebaseFirestore.instance
                                                    .collection('UserData')
                                                    .doc(currentUser?.uid)
                                                    .update({
                                                  "shippingAddress":
                                                      _shippingAddressController
                                                          .text,
                                                }).then((value) => showFlash(
                                                          context: context,
                                                          duration:
                                                              const Duration(
                                                                  seconds: 2),
                                                          builder: (context,
                                                              controller) {
                                                            return Flash.bar(
                                                              controller:
                                                                  controller,
                                                              backgroundColor:
                                                                  Colors.green,
                                                              position:
                                                                  FlashPosition
                                                                      .top,
                                                              child: Container(
                                                                  width: MediaQuery.of(
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
                                                                        "Shipping Address Updated Successfully",
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              18,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )),
                                                            );
                                                          },
                                                        ));
                                                Future.delayed(
                                                    const Duration(seconds: 2),
                                                    () {});
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            child: Text('Save',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600)),
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
                          leading: Icon(Icons.location_on_outlined,
                              size: 32, color: Color(0xff2C6846)),
                          title: Wrap(
                            children: <Widget>[
                              Row(
                                children: [
                                  Text(
                                    "Delivery Address",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              Row(
                                children: [
                                  Text(
                                    (snapshot.data
                                        as Map<String, dynamic>)['name'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    " | ",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    (snapshot.data
                                        as Map<String, dynamic>)['phone'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 270.0,
                                    child: Text(
                                      (snapshot.data as Map<String, dynamic>)[
                                          'shippingAddress'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 40.0,
                              ),
                            ],
                          ),
                          trailing: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.chevron_right,
                                size: 26,
                                color: Colors.black,
                              )
                            ],
                          ),
                        ),
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
                        Flexible(
                          child: StreamBuilder(
                              stream: DatabaseManager()
                                  .getCartList(currentUser!.uid),
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
                                        margin:
                                            EdgeInsets.fromLTRB(0, 15, 0, 15),
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
                                                    child: SizedBox(height: 40),
                                                  ),
                                                  WidgetSpan(
                                                    child: Text(
                                                      "RM",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                  ),
                                                  WidgetSpan(
                                                    child: Transform.translate(
                                                      offset: const Offset(
                                                          0.0, 0.0),
                                                      child: Text(
                                                        "${snapshot.data!.docs[index]["price"]}",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black54),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            leading: CachedNetworkImage(
                                              width: 65,
                                              height: 120,
                                              imageUrl: snapshot.data!
                                                  .docs[index]["itemImage"],
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
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
                                              errorWidget:
                                                  (context, url, error) =>
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
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                              }),
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
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                            trailing: Text(
                              "RM839.00",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                          child: ListTile(
                            title: Text(
                              "Shipping Subtotal",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                            trailing: Text(
                              "RM6.00",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ),
                        ),
                      ]);
                    }
                  } else if (snapshot.hasError) {
                    return Text('no data');
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
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
                      Container(
                          padding: EdgeInsets.only(top: 10, right: 10),
                          child: Text("TESTING")),
                      ButtonTheme(
                        buttonColor: Color(0xff2C6846),
                        minWidth: MediaQuery.of(context).size.width * 0.3,
                        height: 60.0,
                        child: RaisedButton(
                          padding: EdgeInsets.fromLTRB(30, 25, 30, 25),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Checkout()));
                          },
                          child: Text('Place Order',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]));
  }
}
