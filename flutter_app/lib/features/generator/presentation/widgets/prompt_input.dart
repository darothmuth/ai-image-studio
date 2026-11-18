import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/voice_input_service.dart';

class PromptInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const PromptInput({super.key, required this.controller, this.onChanged});

  @override
  State<PromptInput> createState() => _PromptInputState();
}

class _PromptInputState extends State<PromptInput> {
  final VoiceInputService _voice = VoiceInputService();
  bool _listening = false;

  Future<void> _toggleListening() async {
    if (_listening) {
      await _voice.stopListening();
      setState(() => _listening = false);
      return;
    }

    final lang = context.read<LocaleProvider>().current;
    final started = await _voice.startListening(
      speechLocale: lang.speechLocale,
      onResult: (text) {
        widget.controller.text = text;
        widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller.text.length),
        );
        widget.onChanged?.call(text);
      },
    );

    if (!mounted) return;

    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Microphone permission is needed for voice input.",
          ),
        ),
      );
      return;
    }
    setState(() => _listening = true);
  }

  @override
  void dispose() {
    _voice.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.palette;
    return Stack(
      children: [
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          maxLength: AppConstants.maxPromptLength,
          maxLines: 4,
          minLines: 3,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: context.t("prompt_hint"),
            counterStyle: TextStyle(color: colors.textSecondary),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: IconButton(
                icon: Icon(
                  _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: _listening ? colors.accent : colors.textSecondary,
                ),
                tooltip: "Voice input",
                onPressed: _toggleListening,
              ),
            ),
          ),
        ),
        if (_listening)
          Positioned(
            right: 52,
            top: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
