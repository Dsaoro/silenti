import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const HomePage(title: 'Silenti'),
    );
  }
}
