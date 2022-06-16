import 'package:flutter/material.dart';
import 'package:flutter_grocery_user/Cart.dart';
import 'package:flutter_grocery_user/Favourite.dart';
import 'package:flutter_grocery_user/Home.dart';
import 'package:flutter_grocery_user/MyOrders.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late PageController _pageController;

  List<Widget> tabs = [Home(), Cart(), Favourite(), MyOrders()];

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: tabs[_selectedIndex],
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedIconTheme: IconThemeData(color: Color(0xff2C6846)),
        selectedItemColor: Color(0xff2C6846),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favourite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'My Orders',
          ),
        ],
      ),
    );
  }
}
