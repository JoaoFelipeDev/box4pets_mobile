import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/app_bar_custom.dart';
import 'package:Box4Pets/core/ui/widgets/parallax_background.dart';
import 'package:Box4Pets/src/pages/destaques/views/destaques.dart';
import 'package:Box4Pets/src/pages/home/views/home.dart';
import 'package:Box4Pets/src/pages/profile/views/profile.dart';
import 'package:Box4Pets/src/pages/tracos_filtro/views/tracos_filtro.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Base extends StatefulWidget {
  const Base({Key? key}) : super(key: key);

  @override
  _BaseState createState() => _BaseState();
}

class _BaseState extends State<Base> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const TracosFiltroPage(),
        ),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ParallaxBackground(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(68),
              child: SafeArea(
                bottom: false,
                child: GestureDetector(
                  onTap: () =>
                      FocusScope.of(context).requestFocus(FocusNode()),
                  child: const AppBarCustom(),
                ),
              ),
            ),
            body: {
              0: Home(onProfileRequested: () => _onItemTapped(3)),
              1: const Destaques(),
              3: const Profile(),
            }[_selectedIndex],
          ),
          Positioned(
            bottom: 18,
            left: 16,
            right: 16,
            child: _ModernBottomNav(
              selectedIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _ModernBottomNav({
    required this.selectedIndex,
    required this.onTap,
  });

  static final _items = <_NavItemData>[
    _NavItemData(
      label: 'Início',
      iconOutline: FontAwesomeIcons.dog,
      iconFilled: FontAwesomeIcons.dog,
    ),
    _NavItemData(
      label: 'Descubra',
      iconOutline: FontAwesomeIcons.paw,
      iconFilled: FontAwesomeIcons.paw,
    ),
    _NavItemData(
      label: 'Doenças & Traços',
      iconOutline: FontAwesomeIcons.dna,
      iconFilled: FontAwesomeIcons.dna,
      isLauncher: true,
    ),
    _NavItemData(
      label: 'Perfil',
      iconOutline: Icons.person_outline_rounded,
      iconFilled: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavButton(
                    data: _items[i],
                    selected: !_items[i].isLauncher && i == selectedIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData iconOutline;
  final IconData iconFilled;
  final bool isLauncher;
  const _NavItemData({
    required this.label,
    required this.iconOutline,
    required this.iconFilled,
    this.isLauncher = false,
  });
}

class _NavButton extends StatelessWidget {
  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;
  const _NavButton({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColor.primary
        : AppColor.primary.withOpacity(0.45);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: Icon(
                selected ? data.iconFilled : data.iconOutline,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 9.5,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: selected ? 16 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
