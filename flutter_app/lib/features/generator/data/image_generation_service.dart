import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/generation_models.dart';

/// AI workflow for this feature:
///
///   User prompt + style
///        |
///        v
///   (optional) POST /api/enhance-prompt   -> LLM rewrites prompt
///        |
///        v
///   POST /api/generate                    -> Image generation model
///        |
///        v
///   GenerationResult (image + metadata) -> Flutter UI
///
/// The backend (not this class) holds the actual model API key.
class ImageGenerationService {
  final ApiClient _apiClient;
  final Uuid _uuid = const Uuid();

  ImageGenerationService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Calls the backend's prompt-enhancement endpoint, which uses an LLM to
  /// turn a short/vague prompt into a more descriptive one.
  Future<String> enhancePrompt(String prompt) async {
    final response = await _apiClient.post(
      AppConstants.enhancePromptEndpoint,
      {"prompt": prompt},
    );
    return response["enhancedPrompt"] as String? ?? prompt;
  }

  /// Requests a generated image for [prompt] rendered in [style].
  Future<GenerationResult> generateImage({
    required String prompt,
    required ImageStyle style,
    String? enhancedPrompt,
  }) async {
    final finalPrompt = "${enhancedPrompt ?? prompt}, ${style.promptSuffix}";

    final response = await _apiClient.post(
      AppConstants.generateEndpoint,
      {
        "prompt": finalPrompt,
        "style": style.id,
      },
    );

    final imageData = response["imageBase64"] ?? response["imageUrl"];
    if (imageData == null) {
      throw const ApiException("The server did not return an image.");
    }

    return GenerationResult(
      id: _uuid.v4(),
      prompt: prompt,
      enhancedPrompt: enhancedPrompt ?? prompt,
      styleId: style.id,
      styleLabel: style.label,
      imageData: imageData as String,
      isBase64: response["imageBase64"] != null,
      createdAt: DateTime.now(),
    );
  }
}
