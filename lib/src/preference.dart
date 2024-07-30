import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  setPref(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  getPref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  dropPref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
