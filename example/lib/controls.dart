import 'package:flutter/material.dart';
import 'main.dart';

class IconControls extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final IconFilter filter;
  final ValueChanged<IconFilter> onFilterChanged;
  final double weight;
  final ValueChanged<double> onWeightChanged;
  final double iconSize;
  final ValueChanged<double> onIconSizeChanged;
  final int iconCount;

  const IconControls({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.filter,
    required this.onFilterChanged,
    required this.weight,
    required this.onWeightChanged,
    required this.iconSize,
    required this.onIconSizeChanged,
    required this.iconCount,
  });

  static const _sizeStops = [16.0, 20.0, 24.0, 28.0, 32.0, 36.0, 40.0, 44.0, 48.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.5),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Tabler Icons',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text('$iconCount icons', style: labelStyle),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search icons...',
            prefixIcon: const Icon(Icons.search, size: 20),
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.primary.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),
        Row(
          spacing: 8,
          children: [
            for (final f in IconFilter.values)
              Expanded(
                child: GestureDetector(
                  onTap: () => onFilterChanged(f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: filter == f
                          ? theme.colorScheme.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: filter == f
                            ? theme.colorScheme.primary.withOpacity(0.4)
                            : theme.colorScheme.onSurface.withOpacity(0.15),
                      ),
                    ),
                    child: Text(
                      f.name[0].toUpperCase() + f.name.substring(1),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: filter == f
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _SliderRow(
          label: 'Stroke',
          value: weight,
          valueLabel: 'w${weight.round()}',
          min: 200,
          max: 400,
          divisions: 2,
          onChanged: onWeightChanged,
        ),
        const SizedBox(height: 8),
        _SliderRow(
          label: 'Size',
          value: iconSize,
          valueLabel: '${iconSize.round()}px',
          min: 16,
          max: 48,
          divisions: _sizeStops.length - 1,
          onChanged: (v) {
            final snapped = _sizeStops.reduce(
              (a, b) => (v - a).abs() < (v - b).abs() ? a : b,
            );
            onIconSizeChanged(snapped);
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Icons by tabler.io',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.3),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            )),
            Text(valueLabel, style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
            )),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
