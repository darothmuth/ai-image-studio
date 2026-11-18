import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// The AI model returns PNG bytes (base64). The app saves/shares as JPG
/// per the project requirement, so this decodes PNG -> re-encodes JPG.
class ImageSaveUtil {
  ImageSaveUtil._();

  /// Decodes [base64Png], re-encodes as JPG, writes it to a temp file and
  /// returns the file path. Returns null if decoding fails.
  static Future<String?> saveBase64AsJpg(
    String base64Png, {
    String? fileNamePrefix,
    int quality = 92,
  }) async {
    try {
      final Uint8List pngBytes = base64Decode(base64Png);
      final decoded = img.decodePng(pngBytes);
      if (decoded == null) return null;

      final jpgBytes = img.encodeJpg(decoded, quality: quality);

      final dir = await getTemporaryDirectory();
      final name =
          "${fileNamePrefix ?? 'ai_image'}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final file = File("${dir.path}/$name");
      await file.writeAsBytes(jpgBytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
