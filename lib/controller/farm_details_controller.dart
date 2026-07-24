import 'package:flutter/material.dart';
import 'package:nakeel_demo/services/database_helper.dart';

class FarmDetailsController extends ChangeNotifier {
  final int farmId;

  FarmDetailsController({required this.farmId});

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _farm;
  Map<String, dynamic>? get farm => _farm;

  List<Map<String, dynamic>> _palms = [];
  List<Map<String, dynamic>> get palms => _palms;

  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> get employees => _employees;

  // --- الإحصائيات الحسابية ---
  Map<String, int> _typeCounts = {};
  Map<String, int> get typeCounts => _typeCounts;

  int _healthyCount = 0;
  int get healthyCount => _healthyCount;

  int _infectedCount = 0;
  int get infectedCount => _infectedCount;

  Map<String, int> _productionStatusCounts = {};
  Map<String, int> get productionStatusCounts => _productionStatusCounts;

  Future<void> loadFarmDetails() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. جلب بيانات المزرعة الأساسية
      _farm = await DatabaseHelper.instance.getFarmById(farmId);

      // 2. جلب نخيل المزرعة
      _palms = await DatabaseHelper.instance.getPalmsByFarm(farmId);

      // 3. جلب الموظفين المخصصين لهذه المزرعة
      final allUsers = await DatabaseHelper.instance.getAllUsers();
      _employees = [];
      for (var u in allUsers) {
        if (u['is_admin'] == 1) continue; // استثناء المدراء إن أردت

        final userId = u['id'] as int;
        final userFarms = await DatabaseHelper.instance.getFarmsForUser(userId, false);
        bool belongsToThisFarm = userFarms.any((f) => f['id'] == farmId);

        if (belongsToThisFarm) {
          _employees.add(u);
        }
      }

      // 4. إجراء الحسابات الإحصائية والنواتج
      _calculateStats();
    } catch (e) {
      debugPrint("Error loading farm details: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateStats() {
    _typeCounts = {};
    _productionStatusCounts = {};
    _healthyCount = 0;
    _infectedCount = 0;

    for (var palm in _palms) {
      // حساب الأعداد حسب النوع (مجدول، برحي، إلخ)
      final type = (palm['type'] as String?)?.trim();
      final typeKey = (type == null || type.isEmpty) ? "غير محدد" : type;
      _typeCounts[typeKey] = (_typeCounts[typeKey] ?? 0) + 1;

      // حساب الحالة الصحية (سليم / مصاب)
      final health = palm['health_status'] as String? ?? 'healthy';
      if (health == 'healthy' || health == 'سليم') {
        _healthyCount++;
      } else {
        _infectedCount++;
      }

      // حساب حالة النمو والإنتاج (فسيلة، مثمرة، إلخ)
      final prodStatus = palm['production_status'] as String? ?? 'baby';
      String prodKey;
      switch (prodStatus) {
        case 'baby':
        case 'فسيلة':
          prodKey = "فسيلة";
          break;
        case 'producing':
        case 'مثمرة':
          prodKey = "مثمرة";
          break;
        case 'stopped':
        case 'متوقفة':
          prodKey = "متوقفة";
          break;
        default:
          prodKey = prodStatus;
      }
      _productionStatusCounts[prodKey] = (_productionStatusCounts[prodKey] ?? 0) + 1;
    }
  }
}