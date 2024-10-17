import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _keySavedCities = 'savedCities';

  static Future<void> saveCity(String city, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedCities = prefs.getStringList(_keySavedCities) ?? [];
    
    if (!savedCities.contains(city)) {
      savedCities.add(city);
      await prefs.setStringList(_keySavedCities, savedCities);
       ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to Saved Cities'),
      ),
    );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('City is already saved'),
      ),
    );
    }
  }

  static Future<List<String>> loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySavedCities) ?? [];
  }
}
