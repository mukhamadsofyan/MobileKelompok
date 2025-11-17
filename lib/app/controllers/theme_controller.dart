import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final _isDark = false.obs;
  bool get isDark => _isDark.value;

  @override
  void onInit() {
    super.onInit();
    loadTheme(); // Load saat app dibuka
  }

  // Simpan pilihan tema ke SharedPreferences
  Future<void> saveTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  // Ambil tema saat startup
  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? saved = prefs.getBool('isDarkMode');

    if (saved != null) _isDark.value = saved;
  }

  // Toggle tema
  void toggleTheme() {
    _isDark.value = !_isDark.value;
    saveTheme(_isDark.value);
  }
}
