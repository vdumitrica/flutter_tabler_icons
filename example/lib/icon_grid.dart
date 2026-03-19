import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class IconGrid extends StatelessWidget {
  final List<MapEntry<String, IconData>> icons;
  final double iconSize;
  final MapEntry<String, IconData>? selectedIcon;
  final ValueChanged<MapEntry<String, IconData>> onIconTap;

  const IconGrid({
    super.key,
    required this.icons,
    required this.iconSize,
    required this.selectedIcon,
    required this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cellExtent = iconSize + 32;
    final labelColor = theme.colorScheme.onSurface.withOpacity(0.5);
    final selectedBg = theme.colorScheme.primary.withOpacity(0.15);
    final selectedBorder = theme.colorScheme.primary.withOpacity(0.4);

    if (icons.isEmpty) {
      return Center(
        child: Text(
          'No icons found',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth == 0) return const SizedBox.shrink();
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        addAutomaticKeepAlives: false,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: cellExtent,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final entry = icons[index];
          final isSelected = selectedIcon?.key == entry.key;

          return GestureDetector(
            onTap: () => onIconTap(entry),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: selectedBorder)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TablerIcon(entry.value, size: iconSize),
                  const SizedBox(height: 4),
                  Text(
                    entry.key.replaceAll('_', ' '),
                    style: TextStyle(fontSize: 8, color: labelColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
