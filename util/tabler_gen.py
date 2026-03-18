#!/usr/bin/env python3

import argparse
import os
import re
import shutil

# Generates a Flutter class from the given list of icon definitions.
def generate_flutter_class(icon_definitions: list[tuple[str, str, str]]) -> str:
    out = """library flutter_tabler_icons;

import 'package:flutter/widgets.dart';

class TablerIcons {
  TablerIcons._();

"""
    # Some icons need their names changed to work with Dart variable naming.
    name_adjustments = {
        "500px": "fiveHundredPx",
        "360-degrees": "threeHundredSixtyDegrees",
        "1": "one",
        "2": "two",
        "3": "three",
        "4": "four",
        "5": "five",
        "6": "six",
        "7": "seven",
        "8": "eight",
        "9": "nine",
        "0": "zero",
        "42-group": "fortyTwoGroup",
        "00": "zeroZero",
        "100": "hundred",
    }

    processed_icons = {}

    for name, code_point, font_family in icon_definitions:
        original_name = name
        name = name.replace("-", "_")

        for name_adjustment in name_adjustments:
            if name.startswith(name_adjustment):
                name = name.replace(
                    name_adjustment, name_adjustments[name_adjustment], 1
                )

        if name == "switch":
            name = "switch_"

        processed_icons[name] = code_point

        out += f'    static const IconData {name} = IconData(0x{code_point}, fontFamily: "{font_family}", fontPackage: "flutter_tabler_icons");\n'

    out += "\n  static const all = <String, IconData> {\n"

    for icon in processed_icons:
        out += f'    "{icon}": {icon},\n'

    out += "  };\n}\n"

    out += """
class TablerIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final FontWeight? weight;

  const TablerIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.weight,
  });

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final double iconSize = size ?? iconTheme.size ?? 24.0;
    final Color iconColor = color ?? iconTheme.color ?? const Color(0xFF000000);

    // Resolve effective weight from explicit arg or inherited IconTheme.
    final double rawWeight = iconTheme.weight ?? 400;
    final FontWeight resolvedWeight = weight ?? FontWeight.values.firstWhere(
      (fw) => fw.value == rawWeight.round(),
      orElse: () => FontWeight.w400,
    );

    // Explicitly select the correct font family for each weight.
    // Flutter does NOT reliably select among static TTF files using fontWeight alone.
    final String base = icon.fontFamily ?? 'tabler-icons';
    final String resolvedFamily;
    if (base == 'tabler-icons') {
      resolvedFamily = resolvedWeight == FontWeight.w200
          ? 'tabler-icons-200'
          : resolvedWeight == FontWeight.w300
              ? 'tabler-icons-300'
              : 'tabler-icons';
    } else {
      resolvedFamily = base;
    }

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Center(
        child: Text(
          String.fromCharCode(icon.codePoint),
          style: TextStyle(
            inherit: false,
            fontFamily: resolvedFamily,
            package: icon.fontPackage,
            fontSize: iconSize,
            color: iconColor,
            height: 1.0,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      ),
    );
  }
}
"""

    return out

if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-i",
        "--input",
        help="Tabler Fonts directory",
        required=True,
    )

    parser.add_argument(
        "-o",
        "--output",
        help="Output file for the Dart class",
        required=True,
    )

    parser.add_argument(
        "-to",
        "--ttf-out",
        help="Where to copy the TTF files (directory)",
        required=True,
    )

    args = parser.parse_args()

    # We will collect tuples of (name, code_point, font_family)
    icon_definitions = []

    def parse_css_file(filename, font_family, name_suffix=""):
        css_file_path = os.path.join(args.input, filename)
        if not os.path.exists(css_file_path):
            print(f"Warning: {css_file_path} not found.")
            return

        with open(css_file_path, "r") as input_file:
            css = input_file.read()
            rules = re.findall(r".*:before {\s.*\s}", css)

            for rule in rules:
                name_match = re.search(r"(?<=\.ti-).*?(?=:)", rule)
                code_match = re.search(r'(?<=content: "\\).*(?=";)', rule)

                if name_match and code_match:
                    name = name_match.group() + name_suffix
                    code_point = code_match.group()
                    icon_definitions.append((name, code_point, font_family))

    # Parse regular outline icons
    parse_css_file("tabler-icons.css", "tabler-icons")
    
    # Parse filled icons and append '_filled' to their dart variable name
    parse_css_file("tabler-icons-filled.css", "tabler-icons-filled", name_suffix="-filled")

    flutter_class = generate_flutter_class(icon_definitions)

    with open(args.output, "w") as output_file:
        output_file.write(flutter_class)

    # Ensure output font directory exists
    os.makedirs(args.ttf_out, exist_ok=True)

    def copy_font(font_name):
        src = os.path.join(args.input, "fonts", font_name)
        if os.path.exists(src):
            shutil.copy(src, os.path.join(args.ttf_out, font_name))

    copy_font("tabler-icons.ttf")
    copy_font("tabler-icons-200.ttf")
    copy_font("tabler-icons-300.ttf")
    copy_font("tabler-icons-filled.ttf")
