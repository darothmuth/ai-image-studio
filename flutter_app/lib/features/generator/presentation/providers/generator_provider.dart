import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/services/content_filter_service.dart';
import '../../data/image_generation_service.dart';
import '../../data/models/generation_models.dart';

enum GeneratorStatus { idle, enhancing, generating, success, error }

class GeneratorProvider extends ChangeNotifier {
  final ImageGenerationService _service;
  final LocalStorageService _storage;

  GeneratorProvider({
    ImageGenerationService? service,
    LocalStorageService? storage,
  })  : _service = service ?? ImageGenerationService(),
        _storage = storage ?? LocalStorageService() {
    loadHistory();
  }

  // ---- State ----
  GeneratorStatus status = GeneratorStatus.idle;
  String? errorMessage;
  GenerationResult? currentResult;
  String? enhancedPreview;

  ImageStyle selectedStyle = AppConstants.availableStyles.first;
  List<GenerationResult> history = [];

  bool get isBusy =>
      status == GeneratorStatus.enhancing || status == GeneratorStatus.generating;

  void selectStyle(ImageStyle style) {
    selectedStyle = style;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    history = await _storage.loadHistory();
    notifyListeners();
  }

  /// Optional AI feature: rewrite the user's prompt to be more descriptive
  /// before generating the image.
  Future<void> enhancePrompt(String prompt) async {
    if (prompt.trim().isEmpty) return;
    status = GeneratorStatus.enhancing;
    errorMessage = null;
    notifyListeners();

    try {
      enhancedPreview = await _service.enhancePrompt(prompt.trim());
      status = GeneratorStatus.idle;
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = GeneratorStatus.error;
    } catch (e) {
      errorMessage = "Could not enhance prompt: $e";
      status = GeneratorStatus.error;
    }
    notifyListeners();
  }

  Future<void> generate(String prompt) async {
    if (prompt.trim().isEmpty) {
      errorMessage = "Please describe what you'd like to generate.";
      status = GeneratorStatus.error;
      notifyListeners();
      return;
    }

    // Safety layer 1: block disallowed categories before any network call.
    final blockReason = ContentFilterService.checkPrompt(prompt);
    if (blockReason != null) {
      errorMessage = blockReason;
      status = GeneratorStatus.error;
      notifyListeners();
      return;
    }

    status = GeneratorStatus.generating;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.generateImage(
        prompt: prompt.trim(),
        style: selectedStyle,
        enhancedPrompt: enhancedPreview,
      );
      currentResult = result;
      status = GeneratorStatus.success;
      await _storage.addToHistory(result);
      await loadHistory();
    } on ApiException catch (e) {
      errorMessage = e.message;
      status = GeneratorStatus.error;
    } catch (e) {
      errorMessage = "Unexpected error: $e";
      status = GeneratorStatus.error;
    }
    notifyListeners();
  }

  void clearEnhancedPreview() {
    enhancedPreview = null;
    notifyListeners();
  }

  Future<void> deleteHistoryItem(String id) async {
    await _storage.deleteItem(id);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await _storage.clearHistory();
    await loadHistory();
  }

  void reset() {
    status = GeneratorStatus.idle;
    currentResult = null;
    errorMessage = null;
    enhancedPreview = null;
    notifyListeners();
  }
}
