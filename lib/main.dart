import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/security/login_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Silenti',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: SilentiColors.primary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      //home: const HomePage(title: 'Silenti'),
      home: LoginPage(),
    );
  }
}
