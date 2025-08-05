import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:heroicons/heroicons.dart';
import 'package:weigthtracker/View/body_entry_sheet_view.dart';
import 'package:weigthtracker/View/footer_pages/more_page.dart';
import 'package:weigthtracker/View/profile_settings_page_view.dart';
import 'package:weigthtracker/theme.dart';

import 'package:flutter/material.dart';
import 'package:weigthtracker/View/footer_pages/home_page.dart';
import 'package:weigthtracker/view/footer_pages/goals_page.dart';
import 'package:weigthtracker/view/footer_pages/progress_page.dart';

class Footer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Footer({super.key, required this.currentIndex, required this.onTap});

  Route _createRoute(Widget page, bool slideFromRight) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const beginOffsetRight = Offset(1.0, 0.0); // Slide von rechts
        const beginOffsetLeft = Offset(-1.0, 0.0); // Slide von links
        final begin = slideFromRight ? beginOffsetRight : beginOffsetLeft;
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      unselectedItemColor: AppColors.primaryDark,
      selectedItemColor: AppColors.primary,
      showUnselectedLabels: true,
      selectedFontSize: 12.0,
      unselectedFontSize: 12.0,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index != currentIndex) {
          // Übergabe des Richtungsparameters: wenn neuer Index > aktueller Index -> Slide von rechts
          bool slideFromRight = index > currentIndex;

          onTap(index);

          if (index == 0) {
            Navigator.push(context, _createRoute(HomePage(), slideFromRight));
          } else if (index == 1) {
            Navigator.push(
              context,
              _createRoute(ProgressPage(), slideFromRight),
            );
          } else if (index == 2) {
            // BodyEntrySheet.show kann so bleiben, da es vermutlich ein Dialog oder BottomSheet ist
            BodyEntrySheet.show(context: context);
          } else if (index == 3) {
            Navigator.push(context, _createRoute(GoalsPage(), slideFromRight));
          } else if (index == 4) {
            Navigator.push(context, _createRoute(MorePage(), slideFromRight));
          }
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
            HeroIcons.chartBar,
            style: HeroIconStyle.outline,
            size: 30,
          ),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: HeroIcon(
            HeroIcons.plusCircle,
            style: HeroIconStyle.outline,
            size: 30,
          ),
          label: 'Add',
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
