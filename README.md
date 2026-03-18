# flutter_tabler_icons

The [Tabler Icon Pack](https://github.com/tabler/tabler-icons) in Flutter

Tabler icons version: v3.40.0

## pubspec.yaml
```yml
dependencies:
  flutter:
    sdk: flutter
  flutter_tabler_icons: [latest]
```

## Usage
```Dart
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return new IconButton(
      icon: new Icon(TablerIcons.alarm_smoke),
      onPressed: () { print('Alarm Smoke'); }
     );
  }
}
```

### Filled Icons
You can use the new filled versions of the icons by appending `_filled` to the icon name:
```Dart
Icon(TablerIcons.sparkles_filled)
```

### Stroke Widths
This package supports customizable stroke widths (weights) for the outline icons! However, because standard Flutter `Icon` widgets do not support static font weights properly, you **must use the included `TablerIcon` widget instead of `Icon`** to use lighter weights.

Supported weights:
- `FontWeight.w400` (Default, 2px stroke)
- `FontWeight.w300` (1.5px stroke)
- `FontWeight.w200` (1px stroke)

```Dart
// A thinner icon
TablerIcon(TablerIcons.home_2, weight: FontWeight.w200)

// You can also use IconTheme to apply it globally:
// IconThemeData(weight: 200)
// TablerIcon will automatically inherit from your Theme!
```

## Updating Icons

This package can be updated to use a newer release of Tabler Icons with `tabler_gen.py` in `/util`. It takes the codepoints from the CSS file of the release and generates a Flutter class of all of the icons.

Example:
```bash
python3 ./util/tabler_gen.py -i ./util/node_modules/@tabler/icons-webfont/dist -o ./lib/flutter_tabler_icons.dart -to ./assets/fonts/tabler-icons.ttf
```

![Screenshot of example app](https://github.com/bigbadbob2003/flutter_tabler_icons/raw/master/.github/screenshot_web.png)
![Screenshot of example app](https://github.com/bigbadbob2003/flutter_tabler_icons/raw/master/.github/screenshot.png)
