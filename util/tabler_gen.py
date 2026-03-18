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

    # Copy regular font
    ttf_file_path = os.path.join(args.input, "fonts", "tabler-icons.ttf")
    if os.path.exists(ttf_file_path):
        shutil.copy(ttf_file_path, os.path.join(args.ttf_out, "tabler-icons.ttf"))

    # Copy filled font
    filled_ttf_file_path = os.path.join(args.input, "fonts", "tabler-icons-filled.ttf")
    if os.path.exists(filled_ttf_file_path):
        shutil.copy(filled_ttf_file_path, os.path.join(args.ttf_out, "tabler-icons-filled.ttf"))
