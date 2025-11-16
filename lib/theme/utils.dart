import 'dart:math' as math;
import 'package:flutter/material.dart';

double logScale(BuildContext context, double baseSize) {
  final screenWidth = MediaQuery.of(context).size.width;
  const baseWidth = 390; // largeur de référence
  final ratio = (screenWidth / baseWidth).clamp(0.5, 3.0);
  final scale = 1 + (math.log(ratio) * 0.25);
  return (baseSize * scale).clamp(baseSize * 0.6, baseSize * 1.5);
}
