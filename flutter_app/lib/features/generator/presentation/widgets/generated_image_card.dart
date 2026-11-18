import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/generation_models.dart';

class GeneratedImageCard extends StatelessWidget {
  final GenerationResult result;
  final VoidCallback? onRegenerate;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onTap;

  const GeneratedImageCard({
    super.key,
    required this.result,
    this.onRegenerate,
    this.onSave,
    this.onShare,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.palette;
    return Container(
      decoration: BoxDecoration(
        gradient: colors.cardGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: GestureDetector(
              onTap: onTap,
              child: AspectRatio(
                aspectRatio: 1,
                child: _buildImage(colors),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result.prompt,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: colors.textPrimary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            "Style: ${result.styleLabel}",
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (onRegenerate != null)
                _ActionButton(
                  icon: Icons.refresh_rounded,
                  label: "Regenerate",
                  onTap: onRegenerate!,
                ),
              if (onSave != null) ...[
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.download_rounded,
                  label: "Save",
                  onTap: onSave!,
                ),
              ],
              if (onShare != null) ...[
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.ios_share_rounded,
                  label: "Share",
                  onTap: onShare!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(AppColorPalette colors) {
    if (result.isBase64) {
      try {
        final Uint8List bytes = base64Decode(result.imageData);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return _brokenImagePlaceholder(colors);
      }
    }
    return Image.network(
      result.imageData,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (_, __, ___) => _brokenImagePlaceholder(colors),
    );
  }

  Widget _brokenImagePlaceholder(AppColorPalette colors) {
    return Container(
      color: colors.surfaceVariant,
      child: Center(
        child: Icon(Icons.broken_image_rounded,
            color: colors.textSecondary, size: 40),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.palette;
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: colors.textPrimary),
        label: Text(label,
            style: TextStyle(color: colors.textPrimary, fontSize: 12)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.textSecondary),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
