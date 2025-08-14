import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weigthtracker/Widget/more/profile/profile_birthday_widget.dart';
import 'package:weigthtracker/Widget/more/profile/profile_gender_widget.dart';
import 'package:weigthtracker/Widget/more/profile/profile_height_widget.dart';
import 'package:weigthtracker/Widget/tdee_widget.dart';
import 'package:weigthtracker/Widget/unit_conversion_widget.dart';
import 'package:weigthtracker/Widget/restart_widget.dart';
import 'package:weigthtracker/ViewModel/profile_settings_provider.dart';
import 'package:weigthtracker/model/profile_settings_model.dart';
import 'package:weigthtracker/model/language_settings_storage_model.dart';
import 'package:weigthtracker/theme.dart';
import 'footer_pages/home_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFormComplete = false;
  String _selectedLanguage = 'en';
  bool _isLanguageLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFormCompletion();
    _loadCurrentLanguage();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Loads the currently saved language from storage
  Future<void> _loadCurrentLanguage() async {
    final currentLanguage =
        await LanguageSettingsStorageModel.getSavedLanguage();
    setState(() {
      _selectedLanguage = currentLanguage;
      _isLanguageLoading = false;
    });
  }

  void _checkFormCompletion() {
    final profileSettings = ref.read(profileSettingsProvider);
    setState(() {
      _isFormComplete =
          profileSettings.birthday != null &&
          profileSettings.gender != null &&
          profileSettings.height != null;
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      if (page == 2) {
        _checkFormCompletion();
      }
    });
  }

  /// Completes onboarding and navigates to home page
  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  /// Changes the app language, completes onboarding, and restarts the app
  Future<void> _changeLanguageAndCompleteOnboarding(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });

    // First complete the onboarding
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    // Then save the language
    await LanguageSettingsStorageModel.saveLanguage(languageCode);

    // Show confirmation message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.language + ' updated!'),
          duration: const Duration(seconds: 1),
        ),
      );

      // Wait a moment for the snackbar to show, then restart the app
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        RestartWidget.restartApp(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: _currentPage == 2 && !_isFormComplete
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                children: [
                  _buildWelcomeScreen(),
                  _buildUnitConversionScreen(),
                  _buildUserInfoScreen(),
                  _buildLanguageSelectionScreen(), // Added language selection as final page
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4, // 4 pages total
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primaryLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _currentPage == 2 && !_isFormComplete
                          ? null
                          : () {
                              if (_currentPage < 3) {
                                _pageController.nextPage(
                                  duration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                // On language selection page, complete onboarding
                                _completeOnboarding();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _currentPage == 3
                            ? AppLocalizations.of(context)!.finish
                            : AppLocalizations.of(context)!.next,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 24.0,
        right: 24.0,
        bottom: 24.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.welcomeToWeightTracker,
            style: AppTypography.headline1(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(
              context,
            )!.trackYourWeightSetGoalsAndMonitorYourProgressOverTime,
            style: AppTypography.bodyLarge(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.letsSetupYourProfileToGetStarted,
            style: AppTypography.bodyMedium(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUnitConversionScreen() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 24.0,
        right: 24.0,
        bottom: 24.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.chooseYourUnits,
            style: AppTypography.headline2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(
              context,
            )!.selectYourPreferredUnitsForWeightAndHeightMeasurements,
            style: AppTypography.bodyMedium(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const UnitConversionWidget(),
        ],
      ),
    );
  }

  Widget _buildUserInfoScreen() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 24.0,
        right: 24.0,
        bottom: 24.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.yourInformation,
            style: AppTypography.headline2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(
              context,
            )!.weNeedSomeBasicInformationToCalculateYourGoalsAccurately,
            style: AppTypography.bodyMedium(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const ProfileBirthdayWidget(),
          const SizedBox(height: 16),
          const ProfileGenderWidget(),
          const SizedBox(height: 16),
          const ProfileHeightWidget(),
          const SizedBox(height: 16),
          if (!_isFormComplete)
            Text(
              AppLocalizations.of(context)!.pleaseFillInAllFieldsToContinue,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          const Spacer(),
          Consumer(
            builder: (context, ref, _) {
              ref.listen<ProfileSettings>(profileSettingsProvider, (
                previous,
                current,
              ) {
                _checkFormCompletion();
              });
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  /// Builds the language selection screen as the final onboarding page
  Widget _buildLanguageSelectionScreen() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 24.0,
        right: 24.0,
        bottom: 24.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.chooseYourLanguage,
            style: AppTypography.headline2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.selectYourPreferredLanguageForTheApp,
            style: AppTypography.bodyMedium(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _isLanguageLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount:
                        LanguageSettingsStorageModel.supportedLanguages.length,
                    itemBuilder: (context, index) {
                      final languageCode = LanguageSettingsStorageModel
                          .supportedLanguages
                          .keys
                          .elementAt(index);
                      final languageData = LanguageSettingsStorageModel
                          .supportedLanguages[languageCode]!;
                      final isSelected = _selectedLanguage == languageCode;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.2),
                                  width: 1,
                                ),
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
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1)
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
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            languageCode.toUpperCase(),
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.7)
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
                              _changeLanguageAndCompleteOnboarding(
                                languageCode,
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTDEEScreen() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 24.0,
        right: 24.0,
        bottom: 24.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.yourDailyEnergyNeeds,
            style: AppTypography.headline2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(
              context,
            )!.basedOnYourInformationWeCanEstimateYourDailyCalorieNeeds,
            style: AppTypography.bodyMedium(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const TDEEWidget(),
        ],
      ),
    );
  }
}
