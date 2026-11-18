import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class StyleSelector extends StatelessWidget {
  final ImageStyle selected;
  final ValueChanged<ImageStyle> onSelect;

  const StyleSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.palette;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.availableStyles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final style = AppConstants.availableStyles[index];
          final isSelected = style.id == selected.id;
          return ChoiceChip(
            label: Text("${style.icon}  ${style.label}"),
            selected: isSelected,
            onSelected: (_) => onSelect(style),
            selectedColor: colors.primary,
            backgroundColor: colors.surfaceVariant,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : colors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          );
        },
      ),
    );
  }
}
