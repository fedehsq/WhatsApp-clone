import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/main.dart';

/// Shared preferences manager
class SharedPreferencesManager {
  static late SharedPreferences _preferences;

  static Future<void> initalize() async {
    _preferences = await SharedPreferences.getInstance();
    log('preferences initialized');
  }

  /// Store a key-value data
  static void putData(String key, value) {
    // check the type of 'value' and store it
    if (value is int) {
      _preferences.setInt(key, value);
    } else if (value is String) {
      _preferences.setString(key, value);
    } else if (value is bool) {
      _preferences.setBool(key, value);
    } else if (value is double) {
      _preferences.setDouble(key, value);
    } else if (value is List<String>) {
      _preferences.setStringList(key, value);
    }
    log('preference saved');
  }

/*
  /// Get the value data associated with 'key'.
  static getData(String key) {
    return _preferences.get(key);
  }
*/
  /// Get the stored user infos.
  static getUsername() {
    return _preferences.get(username);
  }

  /// Get the stored token.
  static getProfilePic() {
    return _preferences.get(photo);
  }
  
  /// Get the stored token.
  static getPhoneNumber() {
    return _preferences.get(phoneNumber);
  }

  /// Remove the user from app.
  static void deleteUser() {
    _preferences.remove('user');
  }

  /// Remove the token from app.
  static void deleteToken() {
    _preferences.remove('token');
  }

  /// Remove the value data associated with 'key'
  static void deleteData(String key) {
    _preferences.remove(key);
  }
}
