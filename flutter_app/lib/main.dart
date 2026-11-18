import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'features/generator/presentation/providers/generator_provider.dart';
import 'features/generator/presentation/screens/home_screen.dart';

void main() {
  runApp(const AiImageStudioApp());
}

class AiImageStudioApp extends StatelessWidget {
  const AiImageStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => GeneratorProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return MaterialApp(
            title: "Matrix AI",
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            locale: Locale(localeProvider.code),
            supportedLocales:
                kSupportedLanguages.map((l) => Locale(l.code)).toList(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // If a locale isn't fully supported by Flutter's built-in
            // Material widgets yet, fall back to English for THOSE widgets
            // only — our own UI text (via context.t()) is unaffected.
            localeResolutionCallback: (locale, supported) {
              if (locale != null &&
                  supported.any((l) => l.languageCode == locale.languageCode)) {
                return locale;
              }
              return const Locale("en");
            },
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
