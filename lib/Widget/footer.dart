import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:heroicons/heroicons.dart';
import 'package:weigthtracker/View/profile_settings_page.dart';
import 'package:weigthtracker/theme.dart';

import 'package:flutter/material.dart';
import 'package:weigthtracker/View/home_page.dart';

class Footer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Footer({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const IconData ticket = IconData(
      0xf916,
      fontFamily: 'CupertinoIcons',
      fontPackage: 'cupertino_icons',
    );
    return BottomNavigationBar(
      currentIndex: currentIndex,
      unselectedItemColor: AppColors.surface,
      selectedItemColor: currentIndex == 1
          ? AppColors.primaryVeryLight
          : AppColors.primary,
      showUnselectedLabels: true,
      selectedFontSize: 12.0, // Same size as unselected
      unselectedFontSize: 12.0, // Ensure consistent font size
      type: BottomNavigationBarType.fixed, // Prevents shifting behavior
      onTap: (index) {
        // First call the onTap callback to update the state
        onTap(index);

        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: HeroIcon(
            HeroIcons.calendar,
            style: HeroIconStyle.outline,
            size: 30,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: HeroIcon(
            HeroIcons.ellipsisHorizontal,
            style: HeroIconStyle.outline,
            color: Colors.grey,
            size: 30,
          ),
          label: 'More',
        ),
      ],
    );
  }
}
