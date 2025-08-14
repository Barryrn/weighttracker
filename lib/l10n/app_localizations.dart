import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pl'),
    Locale('pt'),
    Locale('tr'),
  ];

  /// No description provided for @homePage.
  ///
  /// In en, this message translates to:
  /// **'Home Page'**
  String get homePage;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @energyExpenditure.
  ///
  /// In en, this message translates to:
  /// **'Energy Expenditure'**
  String get energyExpenditure;

  /// No description provided for @tdeeCalories.
  ///
  /// In en, this message translates to:
  /// **'TDEE Calories'**
  String get tdeeCalories;

  /// No description provided for @goalWeightTdee.
  ///
  /// In en, this message translates to:
  /// **'Goal Weight TDEE'**
  String get goalWeightTdee;

  /// No description provided for @noImagesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No images available'**
  String get noImagesAvailable;

  /// No description provided for @pleaseUploadImagesToTrackYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Please upload images to track your progress'**
  String get pleaseUploadImagesToTrackYourProgress;

  /// No description provided for @uploadImages.
  ///
  /// In en, this message translates to:
  /// **'Upload Images'**
  String get uploadImages;

  /// No description provided for @viewAllImages.
  ///
  /// In en, this message translates to:
  /// **'View All Images'**
  String get viewAllImages;

  /// No description provided for @imageTimeline.
  ///
  /// In en, this message translates to:
  /// **'Image Timeline'**
  String get imageTimeline;

  /// No description provided for @noComparison.
  ///
  /// In en, this message translates to:
  /// **'No Comparison'**
  String get noComparison;

  /// No description provided for @addMoreEntries.
  ///
  /// In en, this message translates to:
  /// **'Add more entries'**
  String get addMoreEntries;

  /// No description provided for @noSimilarWeightEntryFound.
  ///
  /// In en, this message translates to:
  /// **'No similar weight entry found'**
  String get noSimilarWeightEntryFound;

  /// No description provided for @front.
  ///
  /// In en, this message translates to:
  /// **'front'**
  String get front;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'back'**
  String get back;

  /// No description provided for @side.
  ///
  /// In en, this message translates to:
  /// **'side'**
  String get side;

  /// No description provided for @frontCapital.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get frontCapital;

  /// No description provided for @backCapital.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backCapital;

  /// No description provided for @sideCapital.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get sideCapital;

  /// No description provided for @pic1.
  ///
  /// In en, this message translates to:
  /// **'Pic 1'**
  String get pic1;

  /// No description provided for @pic2.
  ///
  /// In en, this message translates to:
  /// **'Pic 2'**
  String get pic2;

  /// No description provided for @errorLoadingImages.
  ///
  /// In en, this message translates to:
  /// **'No Image uploaded yet'**
  String get errorLoadingImages;

  /// No description provided for @myGoals.
  ///
  /// In en, this message translates to:
  /// **'My Goals'**
  String get myGoals;

  /// No description provided for @moreSettings.
  ///
  /// In en, this message translates to:
  /// **'More Settings'**
  String get moreSettings;

  /// No description provided for @progressPage.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressPage;

  /// No description provided for @addWeightEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addWeightEntry;

  /// No description provided for @fatPercentageCalculator.
  ///
  /// In en, this message translates to:
  /// **'Fat Percentage Calculator'**
  String get fatPercentageCalculator;

  /// No description provided for @neckCircumference.
  ///
  /// In en, this message translates to:
  /// **'Neck Circumference'**
  String get neckCircumference;

  /// No description provided for @waistCircumference.
  ///
  /// In en, this message translates to:
  /// **'Waist Circumference'**
  String get waistCircumference;

  /// No description provided for @hipCircumference.
  ///
  /// In en, this message translates to:
  /// **'Hip Circumference'**
  String get hipCircumference;

  /// No description provided for @calculationFormula.
  ///
  /// In en, this message translates to:
  /// **'Calculation formula'**
  String get calculationFormula;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @errorCalculatingBodyFatPercentage.
  ///
  /// In en, this message translates to:
  /// **'Error calculating body fat percentage'**
  String get errorCalculatingBodyFatPercentage;

  /// No description provided for @calculateBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Calculate Body Fat'**
  String get calculateBodyFat;

  /// No description provided for @calculatedBodyFatPercentage.
  ///
  /// In en, this message translates to:
  /// **'Calculated Body Fat Percentage'**
  String get calculatedBodyFatPercentage;

  /// No description provided for @useThisResult.
  ///
  /// In en, this message translates to:
  /// **'Use This Result'**
  String get useThisResult;

  /// No description provided for @healthSyncSettings.
  ///
  /// In en, this message translates to:
  /// **'Health Sync Settings'**
  String get healthSyncSettings;

  /// No description provided for @compareYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Compare your progress'**
  String get compareYourProgress;

  /// No description provided for @noWeightData.
  ///
  /// In en, this message translates to:
  /// **'No weight data'**
  String get noWeightData;

  /// No description provided for @imageGallery.
  ///
  /// In en, this message translates to:
  /// **'Image Gallery'**
  String get imageGallery;

  /// No description provided for @noImagesMatchTheCurrentFilters.
  ///
  /// In en, this message translates to:
  /// **'No images match the current filters'**
  String get noImagesMatchTheCurrentFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @weightRange.
  ///
  /// In en, this message translates to:
  /// **'Weight Range'**
  String get weightRange;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @imageTypes.
  ///
  /// In en, this message translates to:
  /// **'Image Types'**
  String get imageTypes;

  /// No description provided for @exportToGallery.
  ///
  /// In en, this message translates to:
  /// **'Export to Gallery'**
  String get exportToGallery;

  /// No description provided for @imageSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Image saved to gallery'**
  String get imageSavedToGallery;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @failedToSaveImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to save image'**
  String get failedToSaveImage;

  /// No description provided for @permissionDeniedToSaveImages.
  ///
  /// In en, this message translates to:
  /// **'Permission denied to save images'**
  String get permissionDeniedToSaveImages;

  /// No description provided for @errorSavingImage.
  ///
  /// In en, this message translates to:
  /// **'Error saving image'**
  String get errorSavingImage;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @welcomeToWeightTracker.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Weight Tracker'**
  String get welcomeToWeightTracker;

  /// No description provided for @trackYourWeightSetGoalsAndMonitorYourProgressOverTime.
  ///
  /// In en, this message translates to:
  /// **'Track your weight, set goals, and monitor your progress over time.'**
  String get trackYourWeightSetGoalsAndMonitorYourProgressOverTime;

  /// No description provided for @letsSetupYourProfileToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your profile to get started!'**
  String get letsSetupYourProfileToGetStarted;

  /// No description provided for @chooseYourUnits.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Units'**
  String get chooseYourUnits;

  /// No description provided for @selectYourPreferredUnitsForWeightAndHeightMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred units for weight and height measurements.'**
  String get selectYourPreferredUnitsForWeightAndHeightMeasurements;

  /// No description provided for @yourInformation.
  ///
  /// In en, this message translates to:
  /// **'Your Information'**
  String get yourInformation;

  /// No description provided for @weNeedSomeBasicInformationToCalculateYourGoalsAccurately.
  ///
  /// In en, this message translates to:
  /// **'We need some basic information to calculate your goals accurately.'**
  String get weNeedSomeBasicInformationToCalculateYourGoalsAccurately;

  /// No description provided for @pleaseFillInAllFieldsToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields to continue'**
  String get pleaseFillInAllFieldsToContinue;

  /// No description provided for @yourDailyEnergyNeeds.
  ///
  /// In en, this message translates to:
  /// **'Your Daily Energy Needs'**
  String get yourDailyEnergyNeeds;

  /// No description provided for @basedOnYourInformationWeCanEstimateYourDailyCalorieNeeds.
  ///
  /// In en, this message translates to:
  /// **'Based on your information, we can estimate your daily calorie needs.'**
  String get basedOnYourInformationWeCanEstimateYourDailyCalorieNeeds;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @clickMe.
  ///
  /// In en, this message translates to:
  /// **'Click Me'**
  String get clickMe;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @tagSettings.
  ///
  /// In en, this message translates to:
  /// **'Tag Settings'**
  String get tagSettings;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noTagsFoundAddTagsWhenEnteringWeightData.
  ///
  /// In en, this message translates to:
  /// **'No tags found. Add tags when entering weight data.'**
  String get noTagsFoundAddTagsWhenEnteringWeightData;

  /// No description provided for @deleteTag.
  ///
  /// In en, this message translates to:
  /// **'Delete Tag'**
  String get deleteTag;

  /// No description provided for @areYouSureYouWantToDeleteTheTag.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the tag'**
  String get areYouSureYouWantToDeleteTheTag;

  /// No description provided for @thisWillRemoveItFromAllEntriesInTheDatabase.
  ///
  /// In en, this message translates to:
  /// **'This will remove it from all entries in the database'**
  String get thisWillRemoveItFromAllEntriesInTheDatabase;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @tdeeCalculator.
  ///
  /// In en, this message translates to:
  /// **'TDEE Calculator'**
  String get tdeeCalculator;

  /// No description provided for @unitConversion.
  ///
  /// In en, this message translates to:
  /// **'Unit Conversion'**
  String get unitConversion;

  /// No description provided for @noWeightDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No weight data available'**
  String get noWeightDataAvailable;

  /// No description provided for @averageWeight.
  ///
  /// In en, this message translates to:
  /// **'Average Weight'**
  String get averageWeight;

  /// No description provided for @caloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get caloriesKcal;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @entryDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted successfully'**
  String get entryDeletedSuccessfully;

  /// No description provided for @failedToDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete entry'**
  String get failedToDeleteEntry;

  /// No description provided for @errorDeletingEntry.
  ///
  /// In en, this message translates to:
  /// **'Error deleting entry'**
  String get errorDeletingEntry;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get deleteEntry;

  /// No description provided for @deleteEntryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this entry? This action cannot be undone.'**
  String get deleteEntryConfirmation;

  /// No description provided for @bodyFatPercentage.
  ///
  /// In en, this message translates to:
  /// **'Body Fat Percentage (%)'**
  String get bodyFatPercentage;

  /// No description provided for @viewPhoto.
  ///
  /// In en, this message translates to:
  /// **'View Photo'**
  String get viewPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhoto;

  /// No description provided for @cameraPermissionIsRequiredToTakePhotos.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to take photos'**
  String get cameraPermissionIsRequiredToTakePhotos;

  /// No description provided for @photosPermissionIsRequiredToSelectImages.
  ///
  /// In en, this message translates to:
  /// **'Photos permission is required to select images'**
  String get photosPermissionIsRequiredToSelectImages;

  /// No description provided for @errorDeletingImage.
  ///
  /// In en, this message translates to:
  /// **'Error deleting image'**
  String get errorDeletingImage;

  /// No description provided for @progressPhotos.
  ///
  /// In en, this message translates to:
  /// **'Progress Photos'**
  String get progressPhotos;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @entrySavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Entry saved successfully'**
  String get entrySavedSuccessfully;

  /// No description provided for @failedToSaveEntry.
  ///
  /// In en, this message translates to:
  /// **'Failed to save entry'**
  String get failedToSaveEntry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @tdeeInformation.
  ///
  /// In en, this message translates to:
  /// **'TDEE Information'**
  String get tdeeInformation;

  /// No description provided for @needToTrackYourInformation.
  ///
  /// In en, this message translates to:
  /// **'You need to track your weight and calorie intake for 7 consecutive days before the TDEE will be available.'**
  String get needToTrackYourInformation;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @weightGoal.
  ///
  /// In en, this message translates to:
  /// **'Weight Goal'**
  String get weightGoal;

  /// No description provided for @setYourStartWeight.
  ///
  /// In en, this message translates to:
  /// **'Set your start weight'**
  String get setYourStartWeight;

  /// No description provided for @setYourGoalWeight.
  ///
  /// In en, this message translates to:
  /// **'Set your goal weight'**
  String get setYourGoalWeight;

  /// No description provided for @yourProgressWillBeTrackedAgainstThisGoal.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be tracked against this goal'**
  String get yourProgressWillBeTrackedAgainstThisGoal;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @noDataAvailableForSelectedMetric.
  ///
  /// In en, this message translates to:
  /// **'No data available for selected metric'**
  String get noDataAvailableForSelectedMetric;

  /// No description provided for @noDataAvailableForThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data available for this time period'**
  String get noDataAvailableForThisPeriod;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @basedOn.
  ///
  /// In en, this message translates to:
  /// **'Based on'**
  String get basedOn;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @adjustHeight.
  ///
  /// In en, this message translates to:
  /// **'Adjust Height'**
  String get adjustHeight;

  /// No description provided for @saveUpper.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get saveUpper;

  /// No description provided for @cancelUpper.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelUpper;

  /// No description provided for @healthIntegration.
  ///
  /// In en, this message translates to:
  /// **'Health Integration'**
  String get healthIntegration;

  /// No description provided for @tdeeCalculatorCalories.
  ///
  /// In en, this message translates to:
  /// **'TDEE Calculator (Calories)'**
  String get tdeeCalculatorCalories;

  /// No description provided for @weightChangeGoalTdee.
  ///
  /// In en, this message translates to:
  /// **'Weight Change Goal TDEE'**
  String get weightChangeGoalTdee;

  /// No description provided for @pleaseEnterAValidPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive number'**
  String get pleaseEnterAValidPositiveNumber;

  /// No description provided for @insufficientDataToCalculateGoalTdee.
  ///
  /// In en, this message translates to:
  /// **'Insufficient data to calculate goal TDEE'**
  String get insufficientDataToCalculateGoalTdee;

  /// No description provided for @weightChangeTdee.
  ///
  /// In en, this message translates to:
  /// **'Weight Change TDEE'**
  String get weightChangeTdee;

  /// No description provided for @basedOnYourWeightChangeAndCalorieIntakeOverTime.
  ///
  /// In en, this message translates to:
  /// **'Based on your weight change and calorie intake over time.'**
  String get basedOnYourWeightChangeAndCalorieIntakeOverTime;

  /// No description provided for @calculationFormulaText.
  ///
  /// In en, this message translates to:
  /// **'This calculation uses the formula: TDEE = (CaloriesConsumed + (WeightChange_kg × 7700)) / Days'**
  String get calculationFormulaText;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'calories'**
  String get calories;

  /// No description provided for @yourEstimatedDailyCalorieNeeds.
  ///
  /// In en, this message translates to:
  /// **'Your estimated daily calorie needs'**
  String get yourEstimatedDailyCalorieNeeds;

  /// No description provided for @infoNoteCalorieTimeCalculation.
  ///
  /// In en, this message translates to:
  /// **'Note: This calculation requires at least 7 consecutive days of weight and calorie data. It will use up to 14 days of continuous data for more accuracy.'**
  String get infoNoteCalorieTimeCalculation;

  /// No description provided for @thisCalculationAutomaticallyUpdatesWhenYouAddNewEntries.
  ///
  /// In en, this message translates to:
  /// **'This calculation automatically updates when you add new entries.'**
  String get thisCalculationAutomaticallyUpdatesWhenYouAddNewEntries;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @syncingWill.
  ///
  /// In en, this message translates to:
  /// **'Syncing will'**
  String get syncingWill;

  /// No description provided for @dataSendToHealthApp.
  ///
  /// In en, this message translates to:
  /// **'Send your weight, body fat percentage, and BMI data to Health App'**
  String get dataSendToHealthApp;

  /// No description provided for @importDataFromHealthApp.
  ///
  /// In en, this message translates to:
  /// **'Import weight, body fat percentage, and BMI measurements from health services'**
  String get importDataFromHealthApp;

  /// No description provided for @keepBothSystemsUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Keep both systems up to date'**
  String get keepBothSystemsUpToDate;

  /// No description provided for @infoHealthServicesNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Health services are not available on your device. This feature requires Apple Health on iOS or Health Connect on Android.'**
  String get infoHealthServicesNotAvailable;

  /// No description provided for @noImagesMatchTheCurrentFilterCriteria.
  ///
  /// In en, this message translates to:
  /// **'No images match the current filter criteria'**
  String get noImagesMatchTheCurrentFilterCriteria;

  /// No description provided for @noImageAvailableForThisView.
  ///
  /// In en, this message translates to:
  /// **'No image available for this view'**
  String get noImageAvailableForThisView;

  /// No description provided for @noImagesAvailableForThisView.
  ///
  /// In en, this message translates to:
  /// **'No images available for this view'**
  String get noImagesAvailableForThisView;

  /// No description provided for @onlyOneImageAvailableForThisView.
  ///
  /// In en, this message translates to:
  /// **'Only one image available for this view'**
  String get onlyOneImageAvailableForThisView;

  /// No description provided for @totalDailyEnergyExpenditureTdee.
  ///
  /// In en, this message translates to:
  /// **'Total Daily Energy Expenditure (TDEE)'**
  String get totalDailyEnergyExpenditureTdee;

  /// No description provided for @kcalPerDay.
  ///
  /// In en, this message translates to:
  /// **'kcal/day'**
  String get kcalPerDay;

  /// No description provided for @notCalculated.
  ///
  /// In en, this message translates to:
  /// **'Not calculated'**
  String get notCalculated;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// No description provided for @infoTextTdeeEstimate.
  ///
  /// In en, this message translates to:
  /// **'This is a first estimate of your TDEE based on age, weight, gender, and activity level.\nFor a more precise result, track your body weight and calorie intake for at least 7 continuous days.'**
  String get infoTextTdeeEstimate;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat:'**
  String get fat;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @fatPercentSign.
  ///
  /// In en, this message translates to:
  /// **'Fat %'**
  String get fatPercentSign;

  /// No description provided for @bodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body Fat'**
  String get bodyFat;

  /// No description provided for @tableView.
  ///
  /// In en, this message translates to:
  /// **'Table View'**
  String get tableView;

  /// No description provided for @graphView.
  ///
  /// In en, this message translates to:
  /// **'Graph View'**
  String get graphView;

  /// No description provided for @chartView.
  ///
  /// In en, this message translates to:
  /// **'Chart View'**
  String get chartView;

  /// No description provided for @entry.
  ///
  /// In en, this message translates to:
  /// **'entry'**
  String get entry;

  /// No description provided for @entries.
  ///
  /// In en, this message translates to:
  /// **'entries'**
  String get entries;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @gainWeight.
  ///
  /// In en, this message translates to:
  /// **'Gain Weight'**
  String get gainWeight;

  /// No description provided for @loseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get loseWeight;

  /// No description provided for @weightChangePerWeek.
  ///
  /// In en, this message translates to:
  /// **'Weight Change per Week'**
  String get weightChangePerWeek;

  /// No description provided for @baseTdee.
  ///
  /// In en, this message translates to:
  /// **'Base TDEE'**
  String get baseTdee;

  /// No description provided for @weightChange.
  ///
  /// In en, this message translates to:
  /// **'Weight Change'**
  String get weightChange;

  /// No description provided for @calorieAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Calorie Adjustment'**
  String get calorieAdjustment;

  /// No description provided for @goalTdee.
  ///
  /// In en, this message translates to:
  /// **'Goal TDEE'**
  String get goalTdee;

  /// No description provided for @kcalDay.
  ///
  /// In en, this message translates to:
  /// **'kcal/day'**
  String get kcalDay;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @kilograms.
  ///
  /// In en, this message translates to:
  /// **'Kilograms'**
  String get kilograms;

  /// No description provided for @pounds.
  ///
  /// In en, this message translates to:
  /// **'Pounds'**
  String get pounds;

  /// No description provided for @centimeters.
  ///
  /// In en, this message translates to:
  /// **'Centimeters'**
  String get centimeters;

  /// No description provided for @inches.
  ///
  /// In en, this message translates to:
  /// **'Inches'**
  String get inches;

  /// No description provided for @sedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary (little or no exercise)'**
  String get sedentary;

  /// No description provided for @lightlyActive.
  ///
  /// In en, this message translates to:
  /// **'Lightly active (1-3 days per week)'**
  String get lightlyActive;

  /// No description provided for @moderatelyActive.
  ///
  /// In en, this message translates to:
  /// **'Moderately Active (moderate exercise 3-5 days/week)'**
  String get moderatelyActive;

  /// No description provided for @veryActive.
  ///
  /// In en, this message translates to:
  /// **'Very Active (hard exercise 6-7 days/week)'**
  String get veryActive;

  /// No description provided for @extraActive.
  ///
  /// In en, this message translates to:
  /// **'Extra Active (very hard exercise & physical job or 2x training)'**
  String get extraActive;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @pleaseSelectYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select your language'**
  String get pleaseSelectYourLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @polish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get polish;

  /// No description provided for @healthServices.
  ///
  /// In en, this message translates to:
  /// **'Health Services'**
  String get healthServices;

  /// No description provided for @availableOnYourDevice.
  ///
  /// In en, this message translates to:
  /// **'Available on your device'**
  String get availableOnYourDevice;

  /// No description provided for @notAvailableOnYourDevice.
  ///
  /// In en, this message translates to:
  /// **'Not available on your device'**
  String get notAvailableOnYourDevice;

  /// No description provided for @authorization.
  ///
  /// In en, this message translates to:
  /// **'Authorization'**
  String get authorization;

  /// No description provided for @accessGranted.
  ///
  /// In en, this message translates to:
  /// **'Access granted'**
  String get accessGranted;

  /// No description provided for @accessNotGranted.
  ///
  /// In en, this message translates to:
  /// **'Access not granted'**
  String get accessNotGranted;

  /// No description provided for @neverSynced.
  ///
  /// In en, this message translates to:
  /// **'Never synced'**
  String get neverSynced;

  /// No description provided for @grantAccess.
  ///
  /// In en, this message translates to:
  /// **'Grant Access'**
  String get grantAccess;

  /// No description provided for @lastSync.
  ///
  /// In en, this message translates to:
  /// **'Last Sync'**
  String get lastSync;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseYourLanguage;

  /// No description provided for @selectYourPreferredLanguageForTheApp.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the app. The app will restart to apply the changes'**
  String get selectYourPreferredLanguageForTheApp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pl',
    'pt',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
