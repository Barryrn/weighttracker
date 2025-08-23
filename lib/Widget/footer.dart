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

/// Footer widget that provides bottom navigation
///
/// This widget creates a static footer that remains at the bottom
/// while page content changes above it. Navigation is handled
/// through callbacks to the parent container.
class Footer extends StatelessWidget {
  /// Current active page index
  final int currentIndex;

  /// Callback function triggered when a footer item is tapped
  final Function(int) onTap;

  const Footer({super.key, required this.currentIndex, required this.onTap});

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
      onTap: onTap,
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
          label: AppLocalizations.of(context)!.more,
        ),
      ],
    );
  }
}
