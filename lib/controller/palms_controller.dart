import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nakeel_demo/services/database_helper.dart';
import 'package:nakeel_demo/services/shared_prefs_helper.dart';

class PalmsController extends ChangeNotifier {
  bool isLoading = false;

  // بيانات المستخدم الحالي والصلاحية
  Map<String, dynamic>? currentUser;
  bool isAdmin = false;
  bool canAdd = false;

  // المزارع المتاحة للمستخدم والمزرعة المحددة حالياً
  List<Map<String, dynamic>> userFarms = [];
  List<Map<String, dynamic>> get farms => userFarms; // Alias لضمان التوافق
  Map<String, dynamic>? selectedFarm;

  // قائمة النخيل للمزرعة المحددة والأبعاد الأقصى للشبكة
  List<Map<String, dynamic>> palms = [];
  int maxRows = 1;
  int maxColumns = 1;

  // الإحصائيات
  int totalPalms = 0;
  int healthyCount = 0;
  int infectedCount = 0;
  int warningCount = 0;

  // البحث والتصفية
  String searchQuery = '';
  String selectedStatusFilter =
      'all'; // 'all', 'healthy', 'infected', 'warning'

  // جلب قائمة النخيل المصفاة بناءً على البحث والحالة الصحية
  List<Map<String, dynamic>> get filteredPalms {
    return palms.where((palm) {
      // 1. فلترة البحث (رقم النخلة أو النوع)
      final query = searchQuery.trim().toLowerCase();
      final numberMatch =
          palm['palm_number']?.toString().contains(query) ?? false;
      final typeMatch = (palm['type'] ?? '').toString().toLowerCase().contains(
        query,
      );
      final matchesSearch = query.isEmpty || numberMatch || typeMatch;

      // 2. فلترة الحالة الصحية
      final status = palm['health_status'] ?? 'healthy';
      final matchesStatus =
          selectedStatusFilter == 'all' || status == selectedStatusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    selectedStatusFilter = status;
    notifyListeners();
  }

  // دالة اختيار المزرعة مع إمكانية إرسال null لعرض "جميع المزارع"
  Future<void> selectFarm(Map<String, dynamic>? farm) async {
    selectedFarm = farm;
    await fetchPalmsForSelectedFarm();
  }

  // تهيئة البيانات الشاملة عند فتح الشاشات
  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    _loadUserData();
    await fetchUserFarms();

    if (userFarms.isNotEmpty) {
      // افتراضياً يفتح المزرعة الأولى للمستخدم
      selectedFarm = userFarms.first;
    } else {
      selectedFarm = null;
    }

    await fetchPalmsForSelectedFarm();
  }

  // 1. قراءة بيانات المستخدم الحالي بصورة مرنة
  void _loadUserData() {
    final userString = SharedPrefsHelper.getString("user");
    if (userString.isNotEmpty) {
      try {
        currentUser = jsonDecode(userString);
        final rawIsAdmin = currentUser?['is_admin'];
        final rawCanAdd = currentUser?['can_add'];

        isAdmin = (rawIsAdmin == 1 || rawIsAdmin == true || rawIsAdmin == '1');
        canAdd = (rawCanAdd == 1 || rawCanAdd == true || rawCanAdd == '1');
      } catch (e) {
        debugPrint("Error parsing user data: $e");
      }
    }
  }

  // 2. جلب المزارع المخصصة للمستخدم
  Future<void> fetchUserFarms() async {
    try {
      final userId = currentUser?['id'] as int?;

      if (isAdmin) {
        userFarms = await DatabaseHelper.instance.getAllFarms();
      } else if (userId != null) {
        userFarms = await DatabaseHelper.instance.getFarmsForUser(
          userId,
          false,
        );
      } else {
        userFarms = [];
      }
    } catch (e) {
      debugPrint("Error fetching user farms: $e");
    }
  }

  // 3. جلب النخيل للمزرعة المحددة فقط
  Future<void> fetchPalmsForSelectedFarm() async {
    isLoading = true;
    notifyListeners();

    try {
      if (selectedFarm != null) {
        final farmId = selectedFarm!['id'] as int;
        palms = await DatabaseHelper.instance.getPalmsByFarm(farmId);
      } else {
        palms = [];
      }

      _calculateGridDimensionsAndStats();
    } catch (e) {
      debugPrint("Error fetching palms: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 4. دالة حذف النخلة
  Future<bool> deletePalm(int palmId) async {
    try {
      final rowsAffected = await DatabaseHelper.instance.deletePalm(palmId);

      if (rowsAffected > 0) {
        await fetchPalmsForSelectedFarm();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error deleting palm: $e");
      return false;
    }
  }

  // 5. حساب أبعاد الشبكة والإحصائيات
  void _calculateGridDimensionsAndStats() {
    int rMax = 1;
    int cMax = 1;
    int healthy = 0;
    int infected = 0;
    int warning = 0;

    for (var p in palms) {
      final r = (p['row_number'] as int?) ?? 1;
      final c = (p['column_number'] as int?) ?? 1;
      if (r > rMax) rMax = r;
      if (c > cMax) cMax = c;

      final status = p['health_status'] ?? 'healthy';
      if (status == 'infected') {
        infected++;
      } else if (status == 'warning') {
        warning++;
      } else {
        healthy++;
      }
    }

    maxRows = rMax;
    maxColumns = cMax;
    totalPalms = palms.length;
    healthyCount = healthy;
    infectedCount = infected;
    warningCount = warning;
  }
}
