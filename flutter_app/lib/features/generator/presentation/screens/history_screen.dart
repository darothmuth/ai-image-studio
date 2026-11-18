import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../providers/generator_provider.dart';
import 'result_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GeneratorProvider>();
    final history = provider.history;

    final colors = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t("history")),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: "Clear all",
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Clear history?"),
                    content: const Text(
                        "This will remove all saved generations from this device."),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel")),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text("Clear")),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await provider.clearHistory();
                }
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.history_rounded,
              title: "No generations yet",
              subtitle: "Images you generate will show up here.",
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = history[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                        color: colors.error,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => provider.deleteHistoryItem(item.id),
                  child: ListTile(
                    tileColor: colors.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: item.isBase64
                            ? Image.memory(base64Decode(item.imageData),
                                fit: BoxFit.cover)
                            : Image.network(item.imageData, fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(item.prompt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textPrimary)),
                    subtitle: Text(
                      "${item.styleLabel} · ${DateFormat.yMMMd().add_jm().format(item.createdAt)}",
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ResultDetailScreen(result: item),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
