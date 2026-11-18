/// Represents one completed image generation, stored in history.
class GenerationResult {
  final String id;
  final String prompt;
  final String enhancedPrompt;
  final String styleId;
  final String styleLabel;

  /// Either a remote URL or a base64-encoded PNG/JPEG, depending on what
  /// the backend/model returns. [isBase64] tells the UI how to render it.
  final String imageData;
  final bool isBase64;

  final DateTime createdAt;

  GenerationResult({
    required this.id,
    required this.prompt,
    required this.enhancedPrompt,
    required this.styleId,
    required this.styleLabel,
    required this.imageData,
    required this.isBase64,
    required this.createdAt,
  });

  factory GenerationResult.fromJson(Map<String, dynamic> json) {
    return GenerationResult(
      id: json["id"] as String,
      prompt: json["prompt"] as String,
      enhancedPrompt: json["enhancedPrompt"] as String? ?? json["prompt"],
      styleId: json["styleId"] as String,
      styleLabel: json["styleLabel"] as String,
      imageData: json["imageData"] as String,
      isBase64: json["isBase64"] as bool? ?? false,
      createdAt: DateTime.parse(json["createdAt"] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "prompt": prompt,
        "enhancedPrompt": enhancedPrompt,
        "styleId": styleId,
        "styleLabel": styleLabel,
        "imageData": imageData,
        "isBase64": isBase64,
        "createdAt": createdAt.toIso8601String(),
      };
}
