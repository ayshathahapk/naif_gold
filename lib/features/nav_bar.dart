import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Screens/alert.dart';
import 'Screens/call.dart';
import 'Screens/more.dart';
import 'Screens/spot.dart';
import 'morepages/showmodelbottomsheet.dart';

class Navpage extends StatefulWidget {
  const Navpage({super.key});

  @override
  State<Navpage> createState() => _NavpageState();
}

int _currentIndex = 0;

List<Widget> _pages = [
  Spot(),
  Ratealert(),
  Profile(),
  More(),
];

class _NavpageState extends State<Navpage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
              canvasColor: Colors.black,
              primaryColor: Colors.red,
              textTheme: Theme.of(context)
                  .textTheme
                  .copyWith(bodySmall: new TextStyle(color: Colors.yellow))),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            showSelectedLabels: true,
            selectedItemColor: Colors.white,
            selectedIconTheme: IconThemeData(
              color: Colors.orangeAccent,
            ),
            unselectedItemColor: Colors.green,
            showUnselectedLabels: false,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard, color: Color(0xFFBFA13A)),
                label: 'Spot rate',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  child: Icon(Icons.notifications_none_rounded,
                      color: Color(0xFFBFA13A)),
                ),
                label: 'Rate alert',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Color(0xFFBFA13A)),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Showpage();
                        },
                      );
                    },
                    child: Icon(Icons.more, color: Color(0xFFBFA13A))),
                label: 'More',
              ),
            ],
          )),
    );
  }
}
