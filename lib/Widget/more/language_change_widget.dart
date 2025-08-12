import 'package:flutter/material.dart';
import 'package:weigthtracker/View/language_change_view.dart';
import 'package:weigthtracker/model/language_settings_storage_model.dart';
import '../../l10n/app_localizations.dart';
import 'package:weigthtracker/theme.dart';

/// Widget for changing the app language
/// Displays a list of supported languages with selection functionality
class LanguageChangeWidget extends StatefulWidget {
  const LanguageChangeWidget({Key? key}) : super(key: key);

  @override
  State<LanguageChangeWidget> createState() => _LanguageChangeWidgetState();
}

class _LanguageChangeWidgetState extends State<LanguageChangeWidget> {
  String _selectedLanguage = 'en';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  /// Loads the currently saved language from storage
  Future<void> _loadCurrentLanguage() async {
    final currentLanguage =
        await LanguageSettingsStorageModel.getSavedLanguage();
    setState(() {
      _selectedLanguage = currentLanguage;
      _isLoading = false;
    });
  }

  /// Changes the app language and saves it to storage
  /// Shows a confirmation message to the user
  Future<void> _changeLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });

    await LanguageSettingsStorageModel.saveLanguage(languageCode);

    // Show confirmation and restart app
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.language +
                ' updated. Please restart the app.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while fetching current language
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Build the language selection list
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: LanguageSettingsStorageModel.supportedLanguages.length,
      itemBuilder: (context, index) {
        final languageCode = LanguageSettingsStorageModel
            .supportedLanguages
            .keys
            .elementAt(index);
        final languageData =
            LanguageSettingsStorageModel.supportedLanguages[languageCode]!;
        final isSelected = _selectedLanguage == languageCode;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.card,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  languageData['flag']!,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            title: Text(
              languageData['name']!,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              languageCode.toUpperCase(),
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : const Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.grey,
                  ),
            onTap: () {
              if (!isSelected) {
                _changeLanguage(languageCode);
              }
            },
          ),
        );
      },
    );
  }
}
