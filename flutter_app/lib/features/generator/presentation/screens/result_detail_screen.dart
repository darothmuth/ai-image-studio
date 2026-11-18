import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/generation_models.dart';

class ResultDetailScreen extends StatelessWidget {
  final GenerationResult result;
  const ResultDetailScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = context.palette;
    return Scaffold(
      appBar: AppBar(title: const Text("Image Detail")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: result.isBase64
                    ? Image.memory(base64Decode(result.imageData),
                        fit: BoxFit.cover)
                    : Image.network(result.imageData, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            _infoRow(colors, "Prompt", result.prompt),
            if (result.enhancedPrompt != result.prompt)
              _infoRow(colors, "AI-Enhanced Prompt", result.enhancedPrompt),
            _infoRow(colors, "Style", result.styleLabel),
            _infoRow(
              colors,
              "Generated",
              DateFormat.yMMMMd().add_jm().format(result.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(AppColorPalette colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: colors.textPrimary)),
        ],
      ),
    );
  }
}
