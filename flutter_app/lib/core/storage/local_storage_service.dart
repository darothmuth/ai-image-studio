import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../features/generator/data/models/generation_models.dart';

/// Persists generation history on-device using SharedPreferences.
///
/// For a production-style deployment, swap this for a backend-backed
/// database table (see backend/README section "Scaling to a real DB")
/// so history syncs across devices — the interface below stays the same.
class LocalStorageService {
  Future<List<GenerationResult>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(AppConstants.historyStorageKey) ?? [];
    return raw
        .map((e) => GenerationResult.fromJson(jsonDecode(e)))
        .toList()
        .reversed
        .toList();
  }

  Future<void> addToHistory(GenerationResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(AppConstants.historyStorageKey) ?? [];
    raw.add(jsonEncode(result.toJson()));
    if (raw.length > AppConstants.maxHistoryItems) {
      raw.removeAt(0);
    }
    await prefs.setStringList(AppConstants.historyStorageKey, raw);
  }

  Future<void> deleteItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(AppConstants.historyStorageKey) ?? [];
    raw.removeWhere((e) => GenerationResult.fromJson(jsonDecode(e)).id == id);
    await prefs.setStringList(AppConstants.historyStorageKey, raw);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.historyStorageKey);
  }
}
