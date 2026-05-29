import 'package:silenti/infraestructure/di/injection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/home_page.dart';
import 'package:silenti/presentation/theme/silenti_themes.dart';
// import 'package:silenti/presentation/security/login_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  configureDependencies();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silenti',
      theme: silentiTheme(),
      darkTheme: silentiDarkTheme(),
      themeMode: ThemeMode.system, // Usa el tema del sistema automáticamente
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      //home: const HomePage(title: 'Silenti'),
      // home: LoginPage(),
      home: const HomePage(title: 'Silenti'),
      debugShowCheckedModeBanner: false,
    );
  }
}
