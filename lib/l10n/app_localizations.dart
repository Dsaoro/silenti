import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// add a new transaction
  ///
  /// In en, this message translates to:
  /// **'register transaction'**
  String get trnasactionRegistration;

  /// home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// income
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// outcome
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// register operation
  ///
  /// In en, this message translates to:
  /// **'Register operation'**
  String get operationRegistration;

  /// deposit registration
  ///
  /// In en, this message translates to:
  /// **'Deposit registration'**
  String get depositRegistration;

  /// spend registration
  ///
  /// In en, this message translates to:
  /// **'Spend registration'**
  String get spendRegistration;

  /// withdrawal registration
  ///
  /// In en, this message translates to:
  /// **'Withdrawal registration'**
  String get withdrawalRegistration;

  ///
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  ///
  ///
  /// In en, this message translates to:
  /// **'Initial amount'**
  String get initialAmount;

  ///
  ///
  /// In en, this message translates to:
  /// **'Account balance'**
  String get accountBalance;

  ///
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get asset;

  ///
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  ///
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountName;

  ///
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get type;

  ///
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// label
  ///
  /// In en, this message translates to:
  /// **'SubCategory'**
  String get subCategory;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Sumary'**
  String get sumary;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get operations;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Frecuency'**
  String get frequency;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get frecDaily;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get frecWeekly;

  /// label
  ///
  /// In en, this message translates to:
  /// **'SemiMonthly'**
  String get frecSemiMonthly;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get frecMonthly;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Anual'**
  String get frecAnual;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get frecOnce;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Items per page'**
  String get itemsPerPage;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Interest rate(E.A.)'**
  String get interestRate;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudget;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Budget name'**
  String get budgetName;

  /// label
  ///
  /// In en, this message translates to:
  /// **'New budget '**
  String get newBudget;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Status '**
  String get status;

  /// message
  ///
  /// In en, this message translates to:
  /// **'Unavailable data'**
  String get unavailableData;

  /// message
  ///
  /// In en, this message translates to:
  /// **'Show on balance'**
  String get balanceIncluded;

  /// message
  ///
  /// In en, this message translates to:
  /// **'By deleting this {item} all information stored in it will be lost, this is an unreversible action.\nDo you want to continue?'**
  String deleteWarning(Object item);

  /// message
  ///
  /// In en, this message translates to:
  /// **'New Account'**
  String get newAccount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
