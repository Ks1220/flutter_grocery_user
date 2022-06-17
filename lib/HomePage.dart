import 'package:flutter/material.dart';
import 'package:flutter_grocery_user/Cart.dart';
import 'package:flutter_grocery_user/Favourite.dart';
import 'package:flutter_grocery_user/Home.dart';
import 'package:flutter_grocery_user/MyOrders.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  final ValueNotifier selectedIndex = ValueNotifier(0);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;

  late List<Widget> tabs = [
    Home(widget.selectedIndex, _pageController),
    Cart(widget.selectedIndex, _pageController),
    Favourite(widget.selectedIndex, _pageController),
    MyOrders()
  ];

  _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex.value = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.selectedIndex.value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.selectedIndex,
        builder: (context, data, _) {
          return Scaffold(
            // body: tabs[_selectedIndex],
            body: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: tabs,
            ),

            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: widget.selectedIndex.value,
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
        });
  }
}
