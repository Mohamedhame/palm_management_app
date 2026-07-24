import 'package:flutter/material.dart';
import 'package:nakeel_demo/routes/add_farm_screen.dart';
import 'package:nakeel_demo/services/database_helper.dart';

class FarmsController extends ChangeNotifier {
  List<Map<String, dynamic>> _farms = [];
  List<Map<String, dynamic>> get farms => _farms;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // جلب المزارع من قاعدة البيانات
  Future<void> loadFarms() async {
    _isLoading = true;
    notifyListeners();

    try {
      _farms = await DatabaseHelper.instance.getAllFarms();
    } catch (e) {
      _farms = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // التوجيه لإضافة أو تعديل مزرعة وتحديث الشاشة تلقائياً عند العودة
  Future<void> navigateToAddOrEdit(
    BuildContext context, [
    Map<String, dynamic>? farm,
  ]) async {
    final bool? shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFarmScreen(farmToEdit: farm)),
    );

    if (shouldRefresh == true) {
      await loadFarms();
    }
  }

  // حفظ المزرعة (إضافة جديدة أو تحديث)
  Future<bool> saveFarm({
    required GlobalKey<FormState> formKey,
    required String name,
    required String location,
    required String area,
    required String spacing,
    required String notes,
    Map<String, dynamic>? farmToEdit,
  }) async {
    if (!formKey.currentState!.validate()) return false;

    final farmData = {
      'name': name.trim(),
      'location': location.trim(),
      'area_in_acres': double.tryParse(area) ?? 0.0,
      'palm_spacing': double.tryParse(spacing) ?? 0.0,
      'notes': notes.trim(),
      'created_at':
          farmToEdit != null
              ? farmToEdit['created_at']
              : DateTime.now().toIso8601String(),
    };

    if (farmToEdit != null) {
      await DatabaseHelper.instance.updateFarm(farmToEdit['id'], farmData);
    } else {
      await DatabaseHelper.instance.insertFarm(farmData);
    }

    return true;
  }
}
