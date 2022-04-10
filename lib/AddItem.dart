import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

import 'package:dotted_border/dotted_border.dart';

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
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  File? _imageFile;
  late String imageUrl;
  DocumentSnapshot? groceryItem;

  String dropdownvalue = 'kg';

  var measurementMatrix = [
    'kg',
    'g',
    'mg',
    'L',
    'mL',
    'lb',
    'piece',
  ];

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

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() => _imageFile = File(image.path));
      String fileName = Path.basename(_imageFile!.path);

      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('$fileName');
      await firebaseStorageRef.putFile(File(image.path));
      setState(() async {
        imageUrl = await firebaseStorageRef.getDownloadURL();
      });
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
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

  showMyDialog() async {
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
                    'Are you sure to delete this image? Once delete, you will required to insert another image.'),
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
              onPressed: () {
                setState(() => _imageFile = null);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showDeleteItemsDialog() async {
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
                    'Are you sure to delete this item? Once deleted, data of this item will be no longer available.'),
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
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65.0,
        iconTheme: IconThemeData(
          color: Color(0xff2C6846), //change your color here
        ),
        title:
            const Text('Item Details', style: TextStyle(color: Colors.black)),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          (widget._isEdit == true
              ? MaterialButton(
                  onPressed: () => {showDeleteItemsDialog()},
                  child: Row(children: <Widget>[
                    Icon(Icons.delete_forever, size: 25, color: Colors.red),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 3, 0),
                      child: Text("Delete Forever",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                          textAlign: TextAlign.center),
                    ))
                  ]),
                )
              : Container())
        ],
      ),
      body: SingleChildScrollView(
        child: Center(child: Text(_itemNameController.text)),
      ),
    );
  }
}
