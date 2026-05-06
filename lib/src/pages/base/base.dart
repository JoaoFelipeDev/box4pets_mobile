import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/app_bar_custom.dart';
import 'package:Box4Pets/core/ui/widgets/side_menu.dart';
import 'package:Box4Pets/src/pages/destaques/views/destaques.dart';
import 'package:Box4Pets/src/pages/home/views/home.dart';
import 'package:Box4Pets/src/pages/profile/views/profile.dart';
import 'package:flutter/material.dart';

class Base extends StatefulWidget {
  const Base({Key? key}) : super(key: key);

  @override
  _BaseState createState() => _BaseState();
}

class _BaseState extends State<Base> {
  bool isMenuActive = false;
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
          child: SideMenu(callback: () {
            setState(() {
              isMenuActive = !isMenuActive;
            });
          }),
        ),
        SafeArea(
          child: Transform.translate(
            offset: Offset(isMenuActive ? 288 : 0, 0),
            child: Transform.scale(
              scale: isMenuActive ? 0.8 : 1,
              child: ClipRRect(
                borderRadius: isMenuActive
                    ? const BorderRadius.all(Radius.circular(24))
                    : const BorderRadius.all(Radius.circular(0)),
                child: Scaffold(
                  backgroundColor: Color(0xffF6F6F6),
                  appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(100),
                      child: GestureDetector(
                        onTap: () => FocusScope.of(context)
                            .requestFocus(new FocusNode()),
                        child: AppBarCustom(callback: () {
                          setState(() {
                            isMenuActive = !isMenuActive;
                          });
                        }),
                      )),
                  body: [
                    const Home(),
                    const Destaques(),
                    const Profile(),
                  ][_selectedIndex],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 13,
          right: 13,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),

                  blurRadius: 7,
                  offset: Offset(0, 8), // changes position of shadow
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BottomNavigationBar(
                backgroundColor: Colors.white.withOpacity(0.85),
                elevation: .8,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Inicio',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.star),
                    label: 'Conteúdo',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Perfil',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: AppColor.primary,
                onTap: _onItemTapped,
              ),
            ),
          ),
        )
      ],
    );
  }
}
