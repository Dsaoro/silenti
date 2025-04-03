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

  /// `Account balance`
  String get accountBalance {
    return Intl.message(
      'Account balance',
      name: 'accountBalance',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get asset {
    return Intl.message('Account', name: 'asset', desc: '', args: []);
  }

  /// `Budget`
  String get budget {
    return Intl.message('Budget', name: 'budget', desc: '', args: []);
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

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: 'label', args: []);
  }

  /// `Update`
  String get type {
    return Intl.message('Update', name: 'type', desc: 'label', args: []);
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

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: 'label', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: 'label', args: []);
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

  /// `Daily`
  String get frecDaily {
    return Intl.message('Daily', name: 'frecDaily', desc: 'label', args: []);
  }

  /// `Weekly`
  String get frecWeekly {
    return Intl.message('Weekly', name: 'frecWeekly', desc: 'label', args: []);
  }

  /// `SemiMonthly`
  String get frecSemiMonthly {
    return Intl.message(
      'SemiMonthly',
      name: 'frecSemiMonthly',
      desc: 'label',
      args: [],
    );
  }

  /// `Monthly`
  String get frecMonthly {
    return Intl.message(
      'Monthly',
      name: 'frecMonthly',
      desc: 'label',
      args: [],
    );
  }

  /// `Anual`
  String get frecAnual {
    return Intl.message('Anual', name: 'frecAnual', desc: 'label', args: []);
  }

  /// `Once`
  String get frecOnce {
    return Intl.message('Once', name: 'frecOnce', desc: 'label', args: []);
  }

  /// `Items per page`
  String get itemsPerPage {
    return Intl.message(
      'Items per page',
      name: 'itemsPerPage',
      desc: 'label',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: 'label', args: []);
  }

  /// `Interest rate(E.A.)`
  String get interestRate {
    return Intl.message(
      'Interest rate(E.A.)',
      name: 'interestRate',
      desc: 'label',
      args: [],
    );
  }

  /// `Warning`
  String get warning {
    return Intl.message('Warning', name: 'warning', desc: 'label', args: []);
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

  /// `Show on balance`
  String get balanceIncluded {
    return Intl.message(
      'Show on balance',
      name: 'balanceIncluded',
      desc: 'message',
      args: [],
    );
  }

  /// `By deleting this {item} all information stored in it will be lost, this is an unreversible action.\nDo you want to continue?`
  String deleteWarning(Object item) {
    return Intl.message(
      'By deleting this $item all information stored in it will be lost, this is an unreversible action.\nDo you want to continue?',
      name: 'deleteWarning',
      desc: 'message',
      args: [item],
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
