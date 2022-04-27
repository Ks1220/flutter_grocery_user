import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddItem extends StatefulWidget {
  final bool _isEdit;
  final String _itemId;
  final String _storeId;

  const AddItem(this._isEdit, this._itemId, this._storeId, {Key? key})
      : super(key: key);

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  User? user = FirebaseAuth.instance.currentUser;
  File? _imageFile;
  late String imageUrl;
  DocumentSnapshot? groceryItem;

  String dropdownvalue = 'kg';

  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _itemDescriptionController = TextEditingController();
  TextEditingController _itemStockController = TextEditingController();
  TextEditingController _itemPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchItemId();
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
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Center(
            child: Column(
              children: [
                CachedNetworkImage(
                  width: 140,
                  height: 140,
                  imageUrl: imageUrl,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
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
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ],
            ),
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
                            _itemPriceController.text,
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
                            "per $dropdownvalue",
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
                  onPressed: () {},
                  child: Text('Add to Cart'),
                )),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
