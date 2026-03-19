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
                      child: IconTheme(
                        data: IconThemeData(weight: _weight),
                        child: DetailView(entry: _selectedIcon!),
                      ),
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
