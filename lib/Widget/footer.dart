import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:heroicons/heroicons.dart';
import 'package:weigthtracker/View/body_entry_sheet_view.dart';
import 'package:weigthtracker/View/footer_pages/more_page.dart';
import 'package:weigthtracker/View/profile_settings_page_view.dart';
import 'package:weigthtracker/theme.dart';

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

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
      unselectedItemColor: Theme.of(context).colorScheme.primaryLight,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      showUnselectedLabels: true,
      selectedFontSize: 12.0,
      unselectedFontSize: 12.0,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index != currentIndex) {
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
            BodyEntrySheet.show(context: context);
          } else if (index == 3) {
            Navigator.push(context, _createRoute(GoalsPage(), slideFromRight));
          } else if (index == 4) {
            Navigator.push(context, _createRoute(MorePage(), slideFromRight));
          }
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: HeroIcon(
            HeroIcons.home,
            style: currentIndex == 0
                ? HeroIconStyle.solid
                : HeroIconStyle.outline,
            size: 30,
          ),
          label: AppLocalizations.of(context)!.home,
        ),
        BottomNavigationBarItem(
          icon: HeroIcon(
            HeroIcons.chartBar,
            style: currentIndex == 1
                ? HeroIconStyle.solid
                : HeroIconStyle.outline,
            size: 30,
          ),
          label: AppLocalizations.of(context)!.progress,
        ),
        BottomNavigationBarItem(
          icon: HeroIcon(
            HeroIcons.plusCircle,
            style: currentIndex == 2
                ? HeroIconStyle.solid
                : HeroIconStyle.outline,
            size: 30,
          ),
          label: AppLocalizations.of(context)!.add,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.monitor_weight,
            size: 30,
            color: currentIndex == 3
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primaryLight,
          ),
          label: AppLocalizations.of(context)!.goals,
        ),
        BottomNavigationBarItem(
          icon: HeroIcon(
            HeroIcons.ellipsisHorizontal,
            style: currentIndex == 4
                ? HeroIconStyle.solid
                : HeroIconStyle.outline,
            size: 30,
          ),
          label: 'More',
        ),
      ],
    );
  }
}
