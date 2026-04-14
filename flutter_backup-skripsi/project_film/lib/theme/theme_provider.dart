import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  late SharedPreferences storage;

  final darkTheme = ThemeData(
    primaryColor: Colors.black,
    brightness: Brightness.dark,
    primaryColorDark: Colors.black,
  );

  final lightTheme = ThemeData(
    primaryColor: Colors.white,
    brightness: Brightness.light,
    primaryColorLight: Colors.white,
  );

  // SAVING STATE, or CACHE



  // DARK MODE TOGGLE ACTION
  toggleTheme() {
    _isDark = !_isDark;
    storage.setBool("isDark", _isDark);
    notifyListeners();
  }

  init() async {
    storage = await SharedPreferences.getInstance();
    _isDark = storage.getBool("isDark")??false;
    notifyListeners();
  }

}