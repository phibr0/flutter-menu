import 'package:flutter/material.dart';

Color typeToColor(String type) {
  switch (type) {
    case 'vegan':
      return Color.fromARGB(255, 80, 245, 86);
    case 'vegetarian':
      return Color.fromARGB(255, 136, 255, 140);
    case 'halal':
      return Color.fromARGB(255, 133, 22, 14);
    default:
      return Colors.white;
  }
}

Color idxToColor(int idx) {
  switch (idx) {
    case 0:
      return Colors.white;
    case 3:
      return Color.fromARGB(255, 80, 245, 86);
    case 2:
      return Color.fromARGB(255, 136, 255, 140);
    case 1:
      return Color.fromARGB(255, 133, 22, 14);
    default:
      return Colors.black;
  }
}
