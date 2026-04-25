import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    await _saveTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF6F61EF),
    scaffoldBackgroundColor: const Color(0xFFF5F6FA),
    cardColor: Colors.white,
    shadowColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF1F4F8),
      foregroundColor: Color(0xFF15161E),
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF15161E)),
      bodyMedium: TextStyle(color: Color(0xFF606A85)),
      bodySmall: TextStyle(color: Color(0xFF606A85)),
      titleLarge: TextStyle(
        fontFamily: 'Outfit',
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF606A85)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6F61EF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6F61EF),
      secondary: Color(0xFF606A85),
      surface: Colors.white,
      surfaceContainer: Color(0xFFE0E0E0),
    ).copyWith(brightness: Brightness.light),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF6F61EF),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    shadowColor: Colors.grey[900]!,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(
        fontFamily: 'Outfit',
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: Colors.white,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6F61EF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6F61EF),
      secondary: Color(0xFF606A85),
      surface: Color(0xFF1E1E1E),
      surfaceContainer: Color(0xFF2C2C2C),
    ).copyWith(brightness: Brightness.dark),
  );
}
