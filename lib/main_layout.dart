import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/appointment_page.dart';
import 'package:flutter_application_1/screens/fav_page.dart';
import 'package:flutter_application_1/screens/home_page.dart';
import 'package:flutter_application_1/screens/profile_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainLayout extends StatefulWidget {
const MainLayout({super.key});

@override
State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
int currentPage = 0;
final PageController _page = PageController();

@override
Widget build (BuildContext context) {
return  Scaffold(
  body: PageView(
    controller: _page,
    onPageChanged: ((value) {
      setState(() {
        currentPage = value;
      });
    }),
    children: const <Widget> [
      HomePage(),
      FavPage(),
      AppointmentPage(),
      ProfilePage()
    ]
  ),
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: currentPage,
    onTap: (page) {
     setState(() {
       currentPage = page;
       _page.jumpToPage(
        page, 
      
       );
     });
    },
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.houseChimneyMedical),label: 'Home'),
      BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.solidHeart),label: 'Favorite'),
      BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.solidCalendarCheck),label: 'Appointments'),
      BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.solidUser),label: 'Profile'),
    ]
  ),
);

}
}