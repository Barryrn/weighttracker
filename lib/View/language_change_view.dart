import 'package:flutter/material.dart';
import '../Widget/more/language_change_widget.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:weigthtracker/theme.dart';
import '../Widget/tdee_widget.dart';
import '../Widget/tdee/weight_change_tdee_widget.dart';

class LanguageChangeView extends StatelessWidget {
  const LanguageChangeView({Key? key}) : super(key: key);

  // @override
  // Widget build(BuildContext context) {
  //   return const LanguageChangeWidget();
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Add GestureDetector to dismiss keyboard when tapping anywhere on the screen
      onTap: () {
        // Hide the keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.language,
            style: AppTypography.headline3(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.textTertiary),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.textPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background2,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [LanguageChangeWidget()]),
          ),
        ),
      ),
    );
  }
}
