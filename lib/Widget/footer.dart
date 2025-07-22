import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:heroicons/heroicons.dart';
import 'package:weigthtracker/View/footer_pages/more_page.dart';
import 'package:weigthtracker/View/profile_settings_page_view.dart';
import 'package:weigthtracker/theme.dart';

import 'package:flutter/material.dart';
import 'package:weigthtracker/View/footer_pages/home_page.dart';
import 'package:weigthtracker/view/footer_pages/goals_page.dart';

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
      unselectedItemColor: AppColors.primaryVeryLight,
      selectedItemColor: currentIndex == 1
          ? AppColors.primary
          : AppColors.primary,
      showUnselectedLabels: true,
      selectedFontSize: 12.0, // Same size as unselected
      unselectedFontSize: 12.0, // Ensure consistent font size
      type: BottomNavigationBarType.fixed, // Prevents shifting behavior
      onTap: (index) {
        // First call the onTap callback to update the state
        onTap(index);

        // Only navigate if the selected index is different from the current index
        if (index != currentIndex) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GoalsPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MorePage()),
            );
          }
        }
        // If index == currentIndex, do nothing (stay on current page)
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
          icon: Icon(Icons.monitor_weight, size: 30),
          label: 'Goals',
        ),
        BottomNavigationBarItem(
          icon: HeroIcon(
            HeroIcons.ellipsisHorizontal,
            style: HeroIconStyle.outline,
            size: 30,
          ),
          label: 'More',
        ),
      ],
    );
  }
}
