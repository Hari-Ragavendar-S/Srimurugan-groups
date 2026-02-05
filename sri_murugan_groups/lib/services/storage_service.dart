import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class StorageService {
  static const String keyIsRegistered = 'local_isRegistered';
  static const String keyIsLoggedIn = 'local_isLoggedIn';
  static const String keyName = 'local_name';
  static const String keyEmail = 'local_email';
  static const String keyPhone = 'local_phone';
  static const String keyAddress = 'local_address';
  static const String keyPassword = 'local_password';
  static const String keyIsMpinSet = 'local_isMpinSet';
  static const String keyMpin = 'local_mpin';
  static const String keyLoans = 'local_loans';
  static const String keyTransactions = 'local_transactions';
  static const String keyAdjustmentRequested = 'local_adjustmentRequested';

  static String _encrypt(String value) {
    var bytes = utf8.encode(value);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<String> getString(String key, {String defaultValue = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<void> setEncryptedString(String key, String value) async {
    final encrypted = _encrypt(value);
    await setString(key, encrypted);
  }

  static Future<bool> verifyEncryptedString(String key, String value) async {
    final stored = await getString(key);
    final encrypted = _encrypt(value);
    return stored == encrypted;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> logout() async {
    await setBool(keyIsLoggedIn, false);
  }
}
