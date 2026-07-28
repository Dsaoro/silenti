// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get transactionRegistration => 'Register transaction';

  @override
  String get home => 'Home';

  @override
  String get income => 'Income';

  @override
  String get spent => 'Expense';

  @override
  String get operationRegistration => 'Register operation';

  @override
  String get depositRegistration => 'Deposit registration';

  @override
  String get spendRegistration => 'Spend registration';

  @override
  String get withdrawalRegistration => 'Withdrawal registration';

  @override
  String get amount => 'Amount';

  @override
  String get initialAmount => 'Initial amount';

  @override
  String get accountBalance => 'Account balance';

  @override
  String get asset => 'Account';

  @override
  String get budget => 'Budget';

  @override
  String get accountName => 'Account name';

  @override
  String get category => 'Category';

  @override
  String get register => 'Register';

  @override
  String get update => 'Update';

  @override
  String get type => 'Type';

  @override
  String get date => 'Date';

  @override
  String get select => 'Select';

  @override
  String get description => 'Description';

  @override
  String get subCategory => 'Subcategory';

  @override
  String get balance => 'Balance';

  @override
  String get summary => 'Summary';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get operations => 'Operations';

  @override
  String get frequency => 'Frequency';

  @override
  String get frecDaily => 'Daily';

  @override
  String get frecWeekly => 'Weekly';

  @override
  String get frecSemiMonthly => 'Semi-monthly';

  @override
  String get frecMonthly => 'Monthly';

  @override
  String get frecAnnual => 'Annual';

  @override
  String get frecOnce => 'Once';

  @override
  String get itemsPerPage => 'Items per page';

  @override
  String get details => 'Details';

  @override
  String get interestRate => 'Interest rate (E.A.)';

  @override
  String get warning => 'Warning';

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String get budgetName => 'Budget name';

  @override
  String get newBudget => 'New budget';

  @override
  String get status => 'Status';

  @override
  String get unavailableData => 'Unavailable data';

  @override
  String get balanceIncluded => 'Show on balance';

  @override
  String deleteWarning(Object item) {
    return 'By deleting this $item all information stored in it will be lost, this is an irreversible action.\nDo you want to continue?';
  }

  @override
  String get newAccount => 'New Account';
}
