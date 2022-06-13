// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery_user/AuthService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_grocery_user/Verify.dart';
// import 'package:flutter_grocery_user/provider/GoogleSignInProvider.dart';
// import 'package:flutter_signin_button/flutter_signin_button.dart';
// import 'package:provider/provider.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StoreDetails extends StatefulWidget {
  final TextEditingController _nameController,
      _phoneController,
      _emailController,
      _passwordController;
  StoreDetails(this._nameController, this._phoneController,
      this._emailController, this._passwordController,
      {Key? key})
      : super(key: key);
  _StoreDetailsState createState() => _StoreDetailsState();
}

class _StoreDetailsState extends State<StoreDetails> {
  final AuthService _auth = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _addressOneController = TextEditingController();
  TextEditingController _addressTwoController = TextEditingController();
  TextEditingController _postalCodeController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _countryController = TextEditingController();

  late String _email, _password, _name, _confirmpass;

  File? _imageFile;
  late String imageUrl;

  @override
  void initState() {
    super.initState();
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
              width: MediaQuery.of(context).size.width,
              height: 70,
              child: Center(
                child: Text(
                  errormessage.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                splashColor: Colors.transparent,
                padding: const EdgeInsets.only(left: 30.0, bottom: 15.0),
                icon: Icon(
                  Icons.arrow_back,
                  size: 35,
                ),
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.black,
              )
            : null,
        title: Image.asset('images/logo-name.png'),
        backgroundColor: new Color(0xffff),
        shadowColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 90.0,
      ),
      body: SingleChildScrollView(
          child: Center(
              child: Column(
        children: <Widget>[
          SizedBox(height: 10.0),
          Container(
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                  text: "Shipping Details",
                  style: TextStyle(
                      fontSize: 26,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
            ),
            width: mediaQueryData.size.width * 0.85,
          ),
          Container(
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                  text:
                      "Please enter your profile details for shipping purposes ",
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      color: Colors.black)),
            ),
            width: mediaQueryData.size.width * 0.85,
          ),
          Container(
            width: mediaQueryData.size.width * 0.85,
            child: Form(
                key: _formKey,
                child: Column(children: [
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _addressOneController,
                    validator: (input) {
                      if (input!.isEmpty) return 'Pleas enter an address';
                    },
                    decoration: InputDecoration(
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        errorStyle: TextStyle(height: 0.4),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 20.0),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff2C6846))),
                        focusColor: Color(0xff2C6846),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Color(0xff2C6846),
                        )),
                        labelStyle: TextStyle(color: Color(0xff2C6846)),
                        labelText: "Address 1",
                        prefixIcon: Icon(Icons.location_on_outlined,
                            color: Color(0xff2C6846))),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _addressTwoController,
                    validator: (input) {
                      if (input!.length < 5)
                        return 'Please enter an appropriate address';
                    },
                    decoration: InputDecoration(
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      errorStyle: TextStyle(height: 0.4),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff2C6846))),
                      focusColor: Color(0xff2C6846),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Color(0xff2C6846),
                      )),
                      labelStyle: TextStyle(color: Color(0xff2C6846)),
                      labelText: "Address 2",
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _postalCodeController,
                          validator: (input) {
                            if (input!.length < 5)
                              return 'Incorrect postal code';
                          },
                          decoration: InputDecoration(
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            errorStyle: TextStyle(height: 0.4),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff2C6846))),
                            focusColor: Color(0xff2C6846),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Color(0xff2C6846),
                            )),
                            labelStyle: TextStyle(color: Color(0xff2C6846)),
                            labelText: "Postal Code",
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          validator: (input) {
                            if (input!.length < 2) return 'State is required';
                          },
                          decoration: InputDecoration(
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            errorStyle: TextStyle(height: 0.4),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff2C6846))),
                            focusColor: Color(0xff2C6846),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Color(0xff2C6846),
                            )),
                            labelStyle: TextStyle(color: Color(0xff2C6846)),
                            labelText: "State",
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _cityController,
                          validator: (input) {
                            if (input!.length < 2) return 'City is required';
                          },
                          decoration: InputDecoration(
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            errorStyle: TextStyle(height: 0.4),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff2C6846))),
                            focusColor: Color(0xff2C6846),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Color(0xff2C6846),
                            )),
                            labelStyle: TextStyle(color: Color(0xff2C6846)),
                            labelText: "City",
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: _countryController,
                          validator: (input) {
                            if (input!.length < 2) return 'Country is required';
                          },
                          decoration: InputDecoration(
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            errorStyle: TextStyle(height: 0.4),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff2C6846))),
                            focusColor: Color(0xff2C6846),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Color(0xff2C6846),
                            )),
                            labelStyle: TextStyle(color: Color(0xff2C6846)),
                            labelText: "Country",
                          ),
                        ),
                      ),
                    ],
                  ),
                ])),
          ),
          SizedBox(height: 20),
          ButtonTheme(
            buttonColor: Color(0xff2C6846),
            minWidth: mediaQueryData.size.width * 0.85,
            height: 60.0,
            child: RaisedButton(
              padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(5.0),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  var user;
                  try {
                    user = await _firebaseAuth.createUserWithEmailAndPassword(
                        email: widget._emailController.text,
                        password: widget._passwordController.text);
                  } on FirebaseAuthException catch (error) {
                    switch (error.code) {
                      case "email-already-in-use":
                        showError(context,
                            "The email entered previously was already in used. Please go to login page.");
                        break;
                    }
                  }
                  FirebaseFirestore.instance
                      .collection('UserData')
                      .doc(user.user!.uid)
                      .set({
                    "uid": _firebaseAuth.currentUser!.uid.toString(),
                    "email": user.user!.email,
                    "phone": widget._phoneController.text,
                    "name": widget._nameController.text,
                    "shippingAddress": _addressOneController.text +
                        " " +
                        _addressTwoController.text +
                        " " +
                        _postalCodeController.text +
                        " " +
                        _cityController.text +
                        " " +
                        _stateController.text +
                        " " +
                        _countryController.text,
                    "isMerchant": false
                  });
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Verify()));
                }
              },
              child: Text('Sign Up',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(height: 10.0),
          Container(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text:
                      "By signing up, you agree to our Terms of Service and Privacy Policy",
                  style: TextStyle(
                      fontSize: 11, fontFamily: 'Roboto', color: Colors.black)),
            ),
            width: 300,
          ),
          SizedBox(height: 10.0),
        ],
      ))),
    );
  }
}
