import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.palette;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.t("settings"))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(context.t("color_mode"),
              style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _ColorModeTile(
            label: "Dark",
            mode: AppColorMode.dark,
            swatch: const Color(0xFF15151F),
            selected: themeProvider.mode == AppColorMode.dark,
            onTap: () => themeProvider.setMode(AppColorMode.dark),
          ),
          _ColorModeTile(
            label: "Light",
            mode: AppColorMode.light,
            swatch: const Color(0xFFFFFFFF),
            selected: themeProvider.mode == AppColorMode.light,
            onTap: () => themeProvider.setMode(AppColorMode.light),
          ),
          _ColorModeTile(
            label: "Pink",
            mode: AppColorMode.pink,
            swatch: const Color(0xFFDB2777),
            selected: themeProvider.mode == AppColorMode.pink,
            onTap: () => themeProvider.setMode(AppColorMode.pink),
          ),
          const SizedBox(height: 28),
          Text(context.t("language"),
              style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Column(
            children: kSupportedLanguages.map((lang) {
              final selected = localeProvider.code == lang.code;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () => localeProvider.setLanguage(lang.code),
                  leading: Radio<String>(
                    value: lang.code,
                    groupValue: localeProvider.code,
                    onChanged: (value) =>
                        localeProvider.setLanguage(value ?? "en"),
                    activeColor: colors.primary,
                  ),
                  title: Text(
                    lang.nativeName,
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  selected: selected,
                  selectedTileColor: colors.surface,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ColorModeTile extends StatelessWidget {
  final String label;
  final AppColorMode mode;
  final Color swatch;
  final bool selected;
  final VoidCallback onTap;

  const _ColorModeTile({
    required this.label,
    required this.mode,
    required this.swatch,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.palette;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: colors.surface,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: swatch, radius: 14),
        title: Text(label, style: TextStyle(color: colors.textPrimary)),
        trailing: selected
            ? Icon(Icons.check_circle_rounded, color: colors.primary)
            : null,
      ),
    );
  }
}
