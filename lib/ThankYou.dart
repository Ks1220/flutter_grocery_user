import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

class ThankYou extends StatefulWidget {
  const ThankYou({Key? key}) : super(key: key);

  @override
  State<ThankYou> createState() => _ThankYouState();
}

class _ThankYouState extends State<ThankYou> {
  double screenWidth = 600;
  double screenHeight = 400;

  User? currentUser = FirebaseAuth.instance.currentUser;

  void initState() {
    super.initState();
    delete();
  }

  delete() async {
    QuerySnapshot snaphsot = await FirebaseFirestore.instance
        .collection('Carts')
        .doc(currentUser!.uid)
        .collection('Item')
        .get();

    for (var message in snaphsot.docs) {
      await FirebaseFirestore.instance
          .collection('Carts')
          .doc(currentUser!.uid)
          .collection('Item')
          .doc(message.data()["id"])
          .delete()
          .then((_) => print('PLEASE DELETE: ${currentUser!.uid}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 170,
              padding: EdgeInsets.all(35),
              decoration: BoxDecoration(
                color: Color(0xff2C6846),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'images/card.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: screenHeight * 0.1),
            Text(
              "Thank You!",
              style: TextStyle(
                color: Color(0xff2C6846),
                fontWeight: FontWeight.w600,
                fontSize: 36,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              "Payment done Successfully",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 17,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Text(
              "Click here to return to cart page",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            SizedBox(height: screenHeight * 0.06),
            Flexible(
              child: ButtonTheme(
                buttonColor: Color(0xff2C6846),
                minWidth: MediaQuery.of(context).size.width * 0.85,
                height: 60.0,
                child: RaisedButton(
                  padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('Back to Cart',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
