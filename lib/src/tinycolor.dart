import 'dart:math' as Math;
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:pigment/pigment.dart';

import 'conversion.dart';
import 'util.dart';

export 'color_extension.dart';

class TinyColor {
  final Color originalColor;
  Color _color;

  TinyColor(Color color)
      : this.originalColor = color,
        _color = color.clone();

  factory TinyColor.fromRGB(
      {required int r, required int g, required int b, int a = 100}) {
    return TinyColor(Color.fromARGB(a, r, g, b));
  }

  factory TinyColor.fromHSL(HSLColor hsl) {
    return TinyColor(hsl.toColor());
  }

  factory TinyColor.fromHSV(HSVColor hsv) {
    return TinyColor(hsv.toColor());
  }

  factory TinyColor.fromString(String string) {
    return TinyColor(Pigment.fromString(string));
  }

  bool isDark() {
    return this.getBrightness() < 128.0;
  }

  bool isLight() {
    return !this.isDark();
  }

  double getBrightness() {
    return (_color.red * 299 + _color.green * 587 + _color.blue * 114) / 1000;
  }

  double getLuminance() {
    return _color.computeLuminance();
  }

  TinyColor setAlpha(int alpha) {
    _color = _color.withAlpha(alpha);
    return this;
  }

  TinyColor setOpacity(double opacity) {
    _color = _color.withOpacity(opacity);
    return this;
  }

  HSVColor toHsv() {
    return colorToHsv(_color);
  }

  HSLColor toHsl() {
    return HSLColor.fromColor(_color);
  }

  String toHex8() => _color.value.toRadixString(16).padLeft(8, '0');

  TinyColor clone() {
    return TinyColor(_color);
  }

  TinyColor lighten([int amount = 10]) {
    final hsl = this.toHsl();
    final lightness = clamp01(hsl.lightness + amount / 100);
    return TinyColor.fromHSL(hsl.withLightness(lightness));
  }

  TinyColor brighten([int amount = 10]) {
    final color = Color.fromARGB(
      _color.alpha,
      Math.max(0, Math.min(255, _color.red - (255 * -(amount / 100)).round())),
      Math.max(
          0, Math.min(255, _color.green - (255 * -(amount / 100)).round())),
      Math.max(0, Math.min(255, _color.blue - (255 * -(amount / 100)).round())),
    );
    return TinyColor(color);
  }

  TinyColor darken([int amount = 10]) {
    final hsl = this.toHsl();
    final lightness = clamp01(hsl.lightness - amount / 100);
    return TinyColor.fromHSL(hsl.withLightness(lightness));
  }

  TinyColor tint([int amount = 10]) {
    return this.mix(input: Color.fromRGBO(255, 255, 255, 1.0), amount: amount);
  }

  TinyColor shade([int amount = 10]) {
    return this.mix(input: Color.fromRGBO(0, 0, 0, 1.0), amount: amount);
  }

  TinyColor desaturate([int amount = 10]) {
    final hsl = this.toHsl();
    final saturation = clamp01(hsl.saturation - amount / 100);
    return TinyColor.fromHSL(hsl.withSaturation(saturation));
  }

  TinyColor saturate([int amount = 10]) {
    final hsl = this.toHsl();
    final saturation = clamp01(hsl.saturation + amount / 100);
    return TinyColor.fromHSL(hsl.withSaturation(saturation));
  }

  TinyColor greyscale() {
    return desaturate(100);
  }

  TinyColor spin(double amount) {
    final hsl = this.toHsl();
    final hue = (hsl.hue + amount) % 360;
    return TinyColor.fromHSL(hsl.withHue(hue < 0 ? 360 + hue : hue);
  }

  TinyColor mix({required Color input, int amount = 50}) {
    final p = amount / 100.0;
    final color = Color.fromARGB(
        ((input.alpha - _color.alpha) * p + _color.alpha).round(),
        ((input.red - _color.red) * p + _color.red).round(),
        ((input.green - _color.green) * p + _color.green).round(),
        ((input.blue - _color.blue) * p + _color.blue).round());
    return TinyColor(color);
  }

  TinyColor complement() {
    final hsl = this.toHsl();
    final hue = (hsl.hue + 180) % 360;
    return TinyColor.fromHSL(hsl.withHue(hue));
  }

  Color get color {
    return _color;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TinyColor &&
          runtimeType == other.runtimeType &&
          color == other.color;

  @override
  int get hashCode => color.hashCode;

  @Deprecated('Use == instead.')
  bool equals(Object other) => this == other;
}

extension _ on Color {
  Color clone() {
    return Color.fromARGB(alpha, red, green, blue);
  }
}
