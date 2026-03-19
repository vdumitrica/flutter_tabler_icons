# Example App: Tabler Icons Browser — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a responsive example app that showcases the `flutter_tabler_icons` package — search, filter, weight/size controls, and icon detail.

**Architecture:** Single-screen `StatefulWidget` with responsive layout (controls-on-top for narrow, sidebar for wide). Four focused files: app entry, controls, icon grid, and detail view. State lives in the main screen widget and is passed down via callbacks.

**Tech Stack:** Flutter, `flutter_tabler_icons` package (local `path: ..` dependency)

**Spec:** `docs/superpowers/specs/2026-03-19-example-app-design.md`

---

## File Structure

```
example/lib/
  main.dart          — app entry, dark theme, responsive scaffold, state management
  controls.dart      — search field, filter chips, stroke slider, size slider
  icon_grid.dart     — GridView.builder with filtered icon list
  detail_view.dart   — icon detail panel (weight comparison, sizes, copy button)
```

All files are created from scratch (replacing the existing barebones `main.dart`).

---

### Task 1: App Shell with Dark Theme and Responsive Layout

**Files:**
- Modify: `example/lib/main.dart`
- Modify: `example/pubspec.yaml` (bump SDK constraint for records/patterns)

- [ ] **Step 1: Update pubspec.yaml SDK constraint**

```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'
```

This enables Dart 3 features (records, patterns, switch expressions) used later.

- [ ] **Step 2: Write main.dart with state, dark theme, and responsive scaffold**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'controls.dart';
import 'icon_grid.dart';
import 'detail_view.dart';

void main() {
  runApp(const TablerIconsApp());
}

enum IconFilter { all, outline, filled }

class TablerIconsApp extends StatelessWidget {
  const TablerIconsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabler Icons',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0f0f1a),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4a3aff),
          brightness: Brightness.dark,
        ),
      ),
      home: const IconBrowserScreen(),
    );
  }
}

class IconBrowserScreen extends StatefulWidget {
  const IconBrowserScreen({super.key});

  @override
  State<IconBrowserScreen> createState() => _IconBrowserScreenState();
}

class _IconBrowserScreenState extends State<IconBrowserScreen> {
  String _searchQuery = '';
  IconFilter _filter = IconFilter.all;
  double _weight = 400;
  double _iconSize = 24;
  MapEntry<String, IconData>? _selectedIcon;

  late List<MapEntry<String, IconData>> _allEntries;

  @override
  void initState() {
    super.initState();
    _allEntries = TablerIcons.all.entries.toList();
  }

  List<MapEntry<String, IconData>> get _filteredIcons {
    return _allEntries.where((e) {
      if (_searchQuery.isNotEmpty &&
          !e.key.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      switch (_filter) {
        case IconFilter.all:
          return true;
        case IconFilter.outline:
          return e.value.fontFamily == 'tabler-icons';
        case IconFilter.filled:
          return e.value.fontFamily == 'tabler-icons-filled';
      }
    }).toList();
  }

  void _onIconTap(MapEntry<String, IconData> entry, bool isWide) {
    setState(() => _selectedIcon = entry);
    if (!isWide) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1a1a2e),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => IconTheme(
          data: IconThemeData(weight: _weight),
          child: DetailView(entry: _selectedIcon!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredIcons;
    final controls = IconControls(
      searchQuery: _searchQuery,
      onSearchChanged: (v) => setState(() {
        _searchQuery = v;
        _selectedIcon = null;
      }),
      filter: _filter,
      onFilterChanged: (f) => setState(() {
        _filter = f;
        _selectedIcon = null;
      }),
      weight: _weight,
      onWeightChanged: (w) => setState(() => _weight = w),
      iconSize: _iconSize,
      onIconSizeChanged: (s) => setState(() => _iconSize = s),
      iconCount: filtered.length,
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            final grid = IconTheme(
              data: IconThemeData(weight: _weight),
              child: IconGrid(
                icons: filtered,
                iconSize: _iconSize,
                selectedIcon: _selectedIcon,
                onIconTap: (entry) => _onIconTap(entry, isWide),
              ),
            );

            if (isWide) {
              return Row(
                children: [
                  SizedBox(
                    width: 240,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: controls,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: grid),
                  if (_selectedIcon != null) ...[
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: 280,
                      child: DetailView(entry: _selectedIcon!),
                    ),
                  ],
                ],
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: controls,
                ),
                const SizedBox(height: 8),
                Expanded(child: grid),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Create stub files so the app compiles**

Create `example/lib/controls.dart`:

```dart
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

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
```

Create `example/lib/icon_grid.dart`:

```dart
import 'package:flutter/material.dart';

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
    return const Placeholder();
  }
}
```

Create `example/lib/detail_view.dart`:

```dart
import 'package:flutter/material.dart';

class DetailView extends StatelessWidget {
  final MapEntry<String, IconData> entry;

  const DetailView({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
```

- [ ] **Step 4: Verify the app compiles and runs**

Run from `example/` directory:
```bash
cd example && flutter run -d 57201FDCQ0038B
```
Expected: App launches with dark background, Placeholder widgets visible.

- [ ] **Step 5: Commit**

```bash
git add example/
git commit -m "feat(example): app shell with responsive layout and dark theme"
```

---

### Task 2: Controls Widget

**Files:**
- Modify: `example/lib/controls.dart`

- [ ] **Step 1: Implement the controls widget**

Replace the `build` method in `controls.dart`:

```dart
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
        // Title + count
        Text(
          'Tabler Icons',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text('$iconCount icons', style: labelStyle),
        const SizedBox(height: 16),

        // Search
        TextField(
          decoration: InputDecoration(
            hintText: 'Search icons...',
            prefixIcon: const Icon(Icons.search, size: 20),
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),

        // Filter chips
        SegmentedButton<IconFilter>(
          segments: const [
            ButtonSegment(value: IconFilter.all, label: Text('All')),
            ButtonSegment(value: IconFilter.outline, label: Text('Outline')),
            ButtonSegment(value: IconFilter.filled, label: Text('Filled')),
          ],
          selected: {filter},
          onSelectionChanged: (s) => onFilterChanged(s.first),
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            textStyle: WidgetStatePropertyAll(theme.textTheme.labelMedium),
          ),
        ),
        const SizedBox(height: 16),

        // Stroke slider
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

        // Size slider
        _SliderRow(
          label: 'Size',
          value: iconSize,
          valueLabel: '${iconSize.round()}px',
          min: 16,
          max: 48,
          divisions: _sizeStops.length - 1,
          onChanged: (v) {
            // Snap to nearest 4dp stop
            final snapped = _sizeStops.reduce(
              (a, b) => (v - a).abs() < (v - b).abs() ? a : b,
            );
            onIconSizeChanged(snapped);
          },
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
```

- [ ] **Step 2: Verify controls render and interact**

Run the app. Controls should be visible at top (narrow) or in sidebar (wide). Sliders should move, search should accept text, filter buttons should toggle.

- [ ] **Step 3: Commit**

```bash
git add example/lib/controls.dart
git commit -m "feat(example): search, filter, stroke and size controls"
```

---

### Task 3: Icon Grid

**Files:**
- Modify: `example/lib/icon_grid.dart`

- [ ] **Step 1: Implement the icon grid**

```dart
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

    return GridView.builder(
      padding: const EdgeInsets.all(12),
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
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: theme.colorScheme.primary.withOpacity(0.4))
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TablerIcon(entry.value, size: iconSize),
                const SizedBox(height: 4),
                Text(
                  entry.key.replaceAll('_', ' '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
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
  }
}
```

- [ ] **Step 2: Verify the grid renders icons, search filters, and tap highlights**

Run the app. Should see a grid of icons with names below. Search should filter. Tapping should highlight (on wide) or show placeholder bottom sheet (on narrow).

- [ ] **Step 3: Commit**

```bash
git add example/lib/icon_grid.dart
git commit -m "feat(example): icon grid with filtering, selection, and lazy rendering"
```

---

### Task 4: Detail View

**Prerequisite:** Task 1 Step 1 (SDK bump to >=3.0.0) must be applied — this task uses Dart 3 record syntax.

**Files:**
- Modify: `example/lib/detail_view.dart`

- [ ] **Step 1: Implement the detail view**

```dart
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
```

- [ ] **Step 2: Verify the detail view works in both layouts**

Run the app:
- **Narrow**: tap an icon → bottom sheet slides up with detail
- **Wide**: tap an icon → right panel appears with detail, sidebar controls stay visible
- Verify weight comparison shows 3 visibly different stroke widths
- Verify copy button copies to clipboard
- Verify filled icons skip the weight row

- [ ] **Step 3: Commit**

```bash
git add example/lib/detail_view.dart
git commit -m "feat(example): icon detail view with weight, size, and counterpart"
```

---

### Task 5: Polish and Final Verification

**Files:**
- Possibly tweak: `example/lib/main.dart`, any other file

- [ ] **Step 1: Test on physical device (narrow layout)**

```bash
cd example && flutter run -d 57201FDCQ0038B
```

Verify:
- Search filters icons in real time
- Filter tabs (All/Outline/Filled) work
- Stroke slider changes icon weight visibly
- Size slider snaps to 4dp increments and resizes icons + grid cells
- Tapping an icon opens bottom sheet with full detail
- Copy button works

- [ ] **Step 2: Test wide layout**

Run on desktop or resize emulator to ≥600px width:
```bash
cd example && flutter run -d macos
```
(or `-d chrome` or `-d linux`)

Verify:
- Three-column layout: sidebar | grid | detail panel
- Detail panel appears only when an icon is selected
- Switching search/filter/weight while detail is open still works

- [ ] **Step 3: Fix any visual polish issues found during testing**

Common things to check:
- Grid cells resize properly with the size slider
- Empty state ("No icons found") shows when search has no matches
- Bottom sheet doesn't overflow on small screens
- Scrolling works in the grid with 6k+ icons

- [ ] **Step 4: Final commit and push**

```bash
git add example/
git commit -m "feat(example): responsive icon browser with search, filters, weight and size controls"
git push origin master
```
