import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  // 1. عمل نسخة Singleton عشان نضمن إننا بنتعامل مع نسخة واحدة فقط في الذاكرة
  static final SharedPrefsHelper _instance = SharedPrefsHelper._internal();
  factory SharedPrefsHelper() => _instance;
  SharedPrefsHelper._internal();

  static SharedPreferences? _prefs;

  // 2. دالة التهيئة (Initialization): بنستدعيها مرة واحدة فقط في الـ main
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== دوال الحفظ (Save Data) ====================

  /// حفظ قيمة نصية (String)
  static Future<bool> saveString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  /// حفظ قيمة منطقية (Bool)
  static Future<bool> saveBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  /// حفظ رقم صحيح (Int)
  static Future<bool> saveInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  /// حفظ رقم عشري (Double)
  static Future<bool> saveDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  // ==================== دوال الاسترجاع (Get Data) ====================

  /// استرجاع نص (String)، ويمكن تحديد قيمة افتراضية إذا كانت المفتاح غير موجود
  static String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  /// استرجاع قيمة منطقية (Bool)
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  /// استرجاع رقم صحيح (Int)
  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  /// item استرجاع رقم عشري (Double)
  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  // ==================== دوال الحذف والتحكم ====================

  /// حذف مفتاح معين من الكاش
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  /// مسح الكاش بالكامل (مثيد ممتاز عند تسجيل الخروج)
  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }

  /// التأكد إذا كان هناك قيمة مسجلة لهذا المفتاح أم لا
  static bool hasKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }
}