import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:margarida/model/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeController extends ChangeNotifier {
  bool _dark = true;

  bool get dark => _dark;

  Color get appBarColor1 =>
      _dark ? const Color(0xFF263238) : const Color(0xFFF5F5F5);
  Color get appBarText1 => _dark ? const Color(0xFFF5F5F5) : Colors.black87;
  Color get title1 => _dark ? const Color(0xFFECEFF1) : Colors.black87;
  Color get title2 => _dark ? const Color(0xFFF5F5F5) : Colors.black54;
  Color get tileTitle1 => _dark ? const Color(0xFFF5F5F5) : Colors.black87;
  Color get tileTitle2 => _dark ? const Color(0xFFF5F5F5) : Colors.black87;
  Color get shadow1 =>
      _dark ? const Color(0xFF607D8B) : const Color(0xFFE0E0E0);

  Color get backgroundColor1 =>
      _dark ? const Color(0xFF263238) : const Color(0xFFF5F5F5);
  Color get cardBackground1 =>
      _dark ? const Color(0xFF37474F) : const Color(0xFFFAFAFA);

  Future<void> setDark() async {
    _dark = true;
    await updateConfig(true);
    notifyListeners();
  }

  Future<void> setLight() async {
    _dark = false;
    await updateConfig(false);
    notifyListeners();
  }

  Future<int?> updateConfig(bool dark) async {
    var config = await Tbconfiguration().select().toSingle();
    config?.darkmode = dark;
    return await config?.save();
  }
}

final themeControllerProvider = ChangeNotifierProvider<ThemeController>((ref) {
  return ThemeController();
});
