import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 160);
  static const standard = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 360);

  static const entranceCurve = Curves.easeOutCubic;
  static const exitCurve = Curves.easeInCubic;
}
