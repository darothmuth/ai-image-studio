import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../../core/widgets/matrix_logo.dart';
import '../../../../core/utils/image_save_util.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/generator_provider.dart';
import '../widgets/prompt_input.dart';
import '../widgets/style_selector.dart';
import '../widgets/generated_image_card.dart';
import 'history_screen.dart';
import 'result_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveImage(
      BuildContext context, String data, bool isBase64) async {
    if (!isBase64) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nothing to save yet.")),
      );
      return;
    }
    final path = await ImageSaveUtil.saveBase64AsJpg(data);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(path != null
            ? "Saved as JPG."
            : "Could not save image. Please try again."),
      ),
    );
  }

  Future<void> _shareImage(String data, bool isBase64) async {
    if (!isBase64) return;
    final path =
        await ImageSaveUtil.saveBase64AsJpg(data, fileNamePrefix: "share");
    if (path == null) return;
    await SharePlus.instance.share(
      ShareParams(
        text: "Generated with Matrix AI",
        files: [XFile(path)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GeneratorProvider>();
    final colors = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MatrixLogo(size: 32),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) =>
                  colors.primaryGradient.createShader(bounds),
              child: const Text(
                "Matrix AI",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: context.t("history"),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.t("settings"),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(context.t("describe_idea"),
                style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            PromptInput(controller: _controller),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: provider.isBusy
                    ? null
                    : () => provider.enhancePrompt(_controller.text),
                icon: Icon(Icons.auto_awesome_rounded,
                    size: 18, color: colors.secondary),
                label: Text(context.t("enhance_with_ai"),
                    style: TextStyle(color: colors.secondary)),
              ),
            ),
            if (provider.status == GeneratorStatus.enhancing)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (provider.enhancedPreview != null)
              _EnhancedPreview(provider: provider),
            const SizedBox(height: 20),
            Text(context.t("choose_style"),
                style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            StyleSelector(
              selected: provider.selectedStyle,
              onSelect: provider.selectStyle,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isBusy
                    ? null
                    : () => provider.generate(_controller.text),
                icon: const Icon(Icons.brush_rounded),
                label: Text(provider.status == GeneratorStatus.generating
                    ? context.t("generating")
                    : context.t("generate_image")),
              ),
            ),
            const SizedBox(height: 28),
            _buildResultArea(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildResultArea(BuildContext context, GeneratorProvider provider) {
    switch (provider.status) {
      case GeneratorStatus.generating:
        return GenerationLoadingWidget(message: context.t("generating"));
      case GeneratorStatus.error:
        return AppErrorWidget(
          message: provider.errorMessage ?? "Something went wrong.",
          onRetry: () => provider.generate(_controller.text),
        );
      case GeneratorStatus.success:
        if (provider.currentResult == null) {
          return EmptyStateWidget(
            icon: Icons.image_outlined,
            title: context.t("no_image_yet"),
            subtitle: context.t("no_image_subtitle"),
          );
        }
        final result = provider.currentResult!;
        return GeneratedImageCard(
          result: result,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ResultDetailScreen(result: result),
            ),
          ),
          onRegenerate: () => provider.generate(_controller.text),
          onSave: () => _saveImage(context, result.imageData, result.isBase64),
          onShare: () => _shareImage(result.imageData, result.isBase64),
        );
      case GeneratorStatus.idle:
      case GeneratorStatus.enhancing:
        return EmptyStateWidget(
          icon: Icons.auto_awesome_rounded,
          title: context.t("no_image_yet"),
          subtitle: context.t("no_image_subtitle"),
        );
    }
  }
}

class _EnhancedPreview extends StatelessWidget {
  final GeneratorProvider provider;
  const _EnhancedPreview({required this.provider});

  @override
  Widget build(BuildContext context) {
    final colors = context.palette;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 16, color: colors.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.enhancedPreview!,
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            color: colors.textSecondary,
            onPressed: provider.clearEnhancedPreview,
          ),
        ],
      ),
    );
  }
}
