# Example App Design: Tabler Icons Browser

A responsive Flutter example app that showcases the `flutter_tabler_icons` package features: icon browsing, search, weight selection, and size preview.

## Layout

Two layout modes based on screen width, breakpoint at 600px.

**Narrow (<600px) — phones:**
Controls stacked on top, icon grid below. Tapping an icon opens a bottom sheet with detail.

```
┌──────────────────┐
│ Title + Count     │
│ [Search field]    │
│ [All|Outline|Fill]│
│ Stroke ──●────    │
│ Size   ────●──    │
├──────────────────┤
│ ◇ ☆ ○ △ □ ♡     │
│ ⬡ ◎ ⊕ ⊞ ⊡ ⬢     │
│ ...               │
└──────────────────┘
  ↑ tap → bottom sheet
```

**Wide (≥600px) — tablets/desktop:**
Three-column: left sidebar controls | icon grid | right detail panel (appears on icon tap).

```
┌────────┬───────────────┬────────┐
│Controls│               │ Detail │
│        │  ◇ ☆ ○ △ □   │        │
│Search  │  ♡ ⬡ ◎ ⊕ ⊞   │  ◇    │
│Filter  │  ⊡ ⬢ ...     │compass │
│Stroke  │               │w2 w3 w4│
│Size    │               │[copy]  │
└────────┴───────────────┴────────┘
```

When no icon is selected on wide layout, the detail panel is hidden and the grid takes the full remaining width.

## State

A single screen manages these values:

| State | Type | Default | Purpose |
|-------|------|---------|---------|
| `searchQuery` | `String` | `''` | Filters icons by name substring |
| `filter` | `enum {all, outline, filled}` | `all` | Which icon set to display |
| `weight` | `double` | `400` | Stroke weight for `IconThemeData`, snaps to 200/300/400 |
| `iconSize` | `double` | `24` | Preview size in grid cells |
| `selectedIcon` | `MapEntry<String, IconData>?` | `null` | Currently selected icon for detail |

## Controls

**Search:** `TextField` that filters `TablerIcons.all` entries by case-insensitive name substring match. Debounced or immediate — for a map of ~6k entries, immediate filtering is fine.

**Filter tabs:** Segmented control with 3 options:
- **All** — shows everything from `TablerIcons.all`
- **Outline** — entries where `iconData.fontFamily == 'tabler-icons'`
- **Filled** — entries where `iconData.fontFamily == 'tabler-icons-filled'`

**Stroke slider:** `Slider` with 3 discrete stops: 200, 300, 400. Label shows current value. Only affects outline icons (filled icons have no weight variants). The entire grid is wrapped in `IconTheme(data: IconThemeData(weight: N))` so all `TablerIcon` instances pick up the weight via `iconTheme.weight`. Do not pass weight directly to individual `TablerIcon` instances — `TablerIcon.weight` accepts `FontWeight?`, not a raw double. The `IconTheme` wrapper is the correct mechanism.

**Note on `fontFamily` filtering:** `IconData.fontFamily` returns the raw family name as stored in the constant (e.g. `"tabler-icons"` or `"tabler-icons-filled"`), not the resolved package path. This is the value to compare against in filter logic.

**Size slider:** `Slider` with discrete 4dp stops: 16, 20, 24, 28, 32, 36, 40, 44, 48. Label shows current value in px. Controls the `size` parameter passed to each `TablerIcon`.

## Icon Grid

- `GridView.builder` with `SliverGridDelegateWithMaxCrossAxisExtent`
- `maxCrossAxisExtent` adapts to `iconSize` (e.g. `iconSize + 32` to leave room for the name label)
- Each cell: `TablerIcon` centered above the icon name in small text
- Lazy rendering via builder pattern (6,131 icons total)
- Tap sets `selectedIcon` → opens bottom sheet (narrow) or populates detail panel (wide)
- Filtered list is computed from `TablerIcons.all.entries` filtered by `searchQuery` and `filter`

## Detail View

Shared widget used in both the bottom sheet (narrow) and right panel (wide). Shows:

1. **Large preview** — the icon at 48px with current weight
2. **Weight comparison** — all 3 weights (w200, w300, w400) rendered side by side with labels. Only for outline icons; filled icons show a single preview.
3. **Icon name** — e.g. `compass`
4. **Usage code** — e.g. `TablerIcons.compass` with a copy-to-clipboard button
5. **Size comparison** — the icon rendered at 16, 24, 32, 48px in a row
6. **Filled/outline counterpart** — if the selected icon is outline and `{name}_filled` exists in `TablerIcons.all`, show the filled variant alongside. If the selected icon is filled, strip the `_filled` suffix and look up the outline counterpart. When a filled icon is selected directly, skip the weight comparison row (filled icons have no weight variants).

## File Structure

```
example/lib/
  main.dart          — app entry, theme, responsive scaffold
  icon_grid.dart     — GridView.builder with filtering/search
  controls.dart      — search, filter chips, sliders
  detail_view.dart   — icon detail (bottom sheet + right panel)
```

## Theme

Dark theme to match the tabler.io aesthetic. No light/dark toggle.

## Not In Scope

- Icon categories/tags (package data doesn't include category metadata)
- Pagination controls (GridView.builder handles lazy rendering natively)
- Light/dark theme toggle
- Export or download functionality
