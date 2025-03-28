// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `register transaction`
  String get trnasactionRegistration {
    return Intl.message(
      'register transaction',
      name: 'trnasactionRegistration',
      desc: 'add a new transaction',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: 'home', args: []);
  }

  /// `Income`
  String get income {
    return Intl.message('Income', name: 'income', desc: 'income', args: []);
  }

  /// `Spent`
  String get spent {
    return Intl.message('Spent', name: 'spent', desc: 'outcome', args: []);
  }

  /// `Register operation`
  String get operationRegistration {
    return Intl.message(
      'Register operation',
      name: 'operationRegistration',
      desc: 'register operation',
      args: [],
    );
  }

  /// `Deposit registration`
  String get depositRegistration {
    return Intl.message(
      'Deposit registration',
      name: 'depositRegistration',
      desc: 'deposit registration',
      args: [],
    );
  }

  /// `Spend registration`
  String get spendRegistration {
    return Intl.message(
      'Spend registration',
      name: 'spendRegistration',
      desc: 'spend registration',
      args: [],
    );
  }

  /// `Withdrawal registration`
  String get withdrawalRegistration {
    return Intl.message(
      'Withdrawal registration',
      name: 'withdrawalRegistration',
      desc: 'withdrawal registration',
      args: [],
    );
  }

  /// `Amount`
  String get amount {
    return Intl.message('Amount', name: 'amount', desc: '', args: []);
  }

  /// `Initial amount`
  String get initialAmount {
    return Intl.message(
      'Initial amount',
      name: 'initialAmount',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Account name`
  String get accountName {
    return Intl.message(
      'Account name',
      name: 'accountName',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: 'label', args: []);
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `Select`
  String get select {
    return Intl.message('Select', name: 'select', desc: 'label', args: []);
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: 'label',
      args: [],
    );
  }

  /// `SubCategory`
  String get subCategory {
    return Intl.message(
      'SubCategory',
      name: 'subCategory',
      desc: 'label',
      args: [],
    );
  }

  /// `Balance`
  String get balance {
    return Intl.message('Balance', name: 'balance', desc: 'label', args: []);
  }

  /// `Sumary`
  String get sumary {
    return Intl.message('Sumary', name: 'sumary', desc: 'label', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: 'label', args: []);
  }

  /// `Operations`
  String get operations {
    return Intl.message(
      'Operations',
      name: 'operations',
      desc: 'label',
      args: [],
    );
  }

  /// `Frecuency`
  String get frequency {
    return Intl.message(
      'Frecuency',
      name: 'frequency',
      desc: 'label',
      args: [],
    );
  }

  /// `daily`
  String get frecDaily {
    return Intl.message('daily', name: 'frecDaily', desc: 'label', args: []);
  }

  /// `weekly`
  String get frecWeekly {
    return Intl.message('weekly', name: 'frecWeekly', desc: 'label', args: []);
  }

  /// `semiMonthly`
  String get frecSemiMonthly {
    return Intl.message(
      'semiMonthly',
      name: 'frecSemiMonthly',
      desc: 'label',
      args: [],
    );
  }

  /// `monthly`
  String get frecMonthly {
    return Intl.message(
      'monthly',
      name: 'frecMonthly',
      desc: 'label',
      args: [],
    );
  }

  /// `anual`
  String get frecAnual {
    return Intl.message('anual', name: 'frecAnual', desc: 'label', args: []);
  }

  /// `once`
  String get frecOnce {
    return Intl.message('once', name: 'frecOnce', desc: 'label', args: []);
  }

  /// `Interest rate`
  String get interestRate {
    return Intl.message(
      'Interest rate',
      name: 'interestRate',
      desc: 'label',
      args: [],
    );
  }

  /// `Unavailable data`
  String get unavailableData {
    return Intl.message(
      'Unavailable data',
      name: 'unavailableData',
      desc: 'message',
      args: [],
    );
  }

  /// `included on balance`
  String get balanceIncluded {
    return Intl.message(
      'included on balance',
      name: 'balanceIncluded',
      desc: 'message',
      args: [],
    );
  }

  /// `New Account`
  String get newAccount {
    return Intl.message(
      'New Account',
      name: 'newAccount',
      desc: 'message',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[Locale.fromSubtags(languageCode: 'en')];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
