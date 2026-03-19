import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class DetailView extends StatelessWidget {
  final MapEntry<String, IconData> entry;

  const DetailView({super.key, required this.entry});

  bool get _isOutline => entry.value.fontFamily == 'tabler-icons';

  String? get _counterpartKey {
    if (_isOutline) {
      final filledKey = '${entry.key}_filled';
      return TablerIcons.all.containsKey(filledKey) ? filledKey : null;
    } else if (entry.key.endsWith('_filled')) {
      final outlineKey = entry.key.substring(0, entry.key.length - '_filled'.length);
      return TablerIcons.all.containsKey(outlineKey) ? outlineKey : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.5),
    );
    final usageCode = 'TablerIcons.${entry.key}';
    final counterpartKey = _counterpartKey;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large preview
          Center(
            child: TablerIcon(entry.value, size: 48, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 16),

          // Icon name
          Center(
            child: Text(
              entry.key.replaceAll('_', ' '),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),

          // Usage code + copy
          Center(
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: usageCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied: $usageCode'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      usageCode,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.copy, size: 14, color: theme.colorScheme.primary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Weight comparison (outline only)
          if (_isOutline) ...[
            Text('WEIGHT', style: labelStyle),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final w in [
                  (200.0, 'w200'),
                  (300.0, 'w300'),
                  (400.0, 'w400'),
                ])
                  Column(
                    children: [
                      IconTheme(
                        data: IconThemeData(weight: w.$1),
                        child: TablerIcon(entry.value, size: 32,
                          color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(w.$2, style: labelStyle),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Size comparison
          Text('SIZE', style: labelStyle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final s in [16.0, 24.0, 32.0, 48.0])
                Column(
                  children: [
                    TablerIcon(entry.value, size: s, color: theme.colorScheme.onSurface),
                    const SizedBox(height: 4),
                    Text('${s.round()}', style: labelStyle),
                  ],
                ),
            ],
          ),

          // Counterpart
          if (counterpartKey != null) ...[
            const SizedBox(height: 24),
            Text(_isOutline ? 'FILLED VARIANT' : 'OUTLINE VARIANT', style: labelStyle),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TablerIcon(entry.value, size: 32, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 16),
                  Icon(Icons.arrow_forward, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(width: 16),
                  TablerIcon(TablerIcons.all[counterpartKey]!, size: 32,
                    color: theme.colorScheme.onSurface),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
