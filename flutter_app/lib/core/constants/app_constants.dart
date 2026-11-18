import 'package:flutter/foundation.dart';

/// Central place for configuration values.
///
/// IMPORTANT (Rule 4 — no secrets in the mobile app):
/// The Flutter app NEVER talks directly to OpenAI/Stability/etc.
/// It only talks to OUR OWN backend, which holds the real API key.
class AppConstants {
  AppConstants._();

  /// Change this to your deployed backend URL.
  /// - Chrome/web        -> http://localhost:3000
  /// - Android emulator -> http://10.0.2.2:3000
  /// - iOS simulator     -> http://localhost:3000
  /// - Physical device   -> http://<your-computer-lan-ip>:3000
  /// - Production        -> https://your-backend.example.com
  ///
  /// For a shareable APK, pass the deployed URL at build time:
  ///   flutter build apk --release --dart-define=BACKEND_URL=https://xxx.onrender.com
  static const String _backendFromBuild =
      String.fromEnvironment("BACKEND_URL", defaultValue: "");

  static String get backendBaseUrl => _backendFromBuild.isNotEmpty
      ? _backendFromBuild
      : (kIsWeb ? "http://localhost:3000" : "http://10.0.2.2:3000");

  static const String generateEndpoint = "/api/generate";
  static const String enhancePromptEndpoint = "/api/enhance-prompt";
  static const String healthEndpoint = "/api/health";

  static const int requestTimeoutSeconds = 60;

  static const int maxPromptLength = 500;
  static const int maxHistoryItems = 100;

  static const String historyStorageKey = "generation_history_v1";

  /// The three-plus required generation styles (Rule: "at least three
  /// generation styles").
  static const List<ImageStyle> availableStyles = [
    ImageStyle(
      id: "realistic",
      label: "Realistic",
      icon: "📷",
      promptSuffix: "photorealistic, high detail, natural lighting, 8k",
    ),
    ImageStyle(
      id: "anime",
      label: "Anime",
      icon: "🎌",
      promptSuffix: "anime style, vibrant colors, cel shading, studio quality",
    ),
    ImageStyle(
      id: "oil_painting",
      label: "Oil Painting",
      icon: "🎨",
      promptSuffix: "oil painting, textured brush strokes, classical art style",
    ),
    ImageStyle(
      id: "cyberpunk",
      label: "Cyberpunk",
      icon: "🌆",
      promptSuffix: "cyberpunk style, neon lights, futuristic, high contrast",
    ),
    ImageStyle(
      id: "watercolor",
      label: "Watercolor",
      icon: "💧",
      promptSuffix: "watercolor painting, soft edges, pastel tones",
    ),
    ImageStyle(
      id: "3d_render",
      label: "3D Render",
      icon: "🧊",
      promptSuffix: "3D render, octane render, studio lighting, high detail",
    ),
  ];
}

class ImageStyle {
  final String id;
  final String label;
  final String icon;
  final String promptSuffix;

  const ImageStyle({
    required this.id,
    required this.label,
    required this.icon,
    required this.promptSuffix,
  });
}
