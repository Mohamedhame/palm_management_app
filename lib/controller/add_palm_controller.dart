import 'package:flutter/material.dart';
import 'package:nakeel_demo/services/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPalmController extends ChangeNotifier {
  bool isLoading = false;
  List<Map<String, dynamic>> farms = [];

  // جلب العميل الخاص بـ Supabase
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> fetchFarms() async {
    isLoading = true;
    notifyListeners();

    try {
      // استخدام الكلاس الجديد لجلب جميع المزارع
      farms = await DatabaseHelper.instance.getAllFarms();
    } catch (e) {
      debugPrint("Error fetching farms: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔍 دالة التحقق من التكرار عبر Supabase
  Future<String?> validatePalmUniqueness({
    required int farmId,
    required int palmNumber,
    int? rowNumber,
    int? columnNumber,
    int? currentPalmId, // يُستخدم لمعرفة هل العملية "تعديل" لتجاوز النخلة نفسها
  }) async {
    try {
      // 1. التثبت من تكرار رقم النخلة داخل نفس المزرعة
      var numberQuery = _client
          .from('palms')
          .select('id')
          .eq('farm_id', farmId)
          .eq('palm_number', palmNumber);

      if (currentPalmId != null) {
        numberQuery = numberQuery.neq('id', currentPalmId);
      }

      final existingNumber = await numberQuery;
      if (existingNumber.isNotEmpty) {
        return "رقم النخلة (#$palmNumber) مستخدم بالفعل في هذه المزرعة!";
      }

      // 2. التثبت من تكرار الموقع (الصف والعمود) داخل نفس المزرعة
      if (rowNumber != null && columnNumber != null) {
        var locationQuery = _client
            .from('palms')
            .select('id')
            .eq('farm_id', farmId)
            .eq('row_number', rowNumber)
            .eq('column_number', columnNumber);

        if (currentPalmId != null) {
          locationQuery = locationQuery.neq('id', currentPalmId);
        }

        final existingLocation = await locationQuery;
        if (existingLocation.isNotEmpty) {
          return "يوجد نخلة أخرى بالفعّل في الموقع (الصف: $rowNumber ، العمود: $columnNumber)!";
        }
      }

      return null; // لا توجد أي تعارضات
    } catch (e) {
      debugPrint("Error validating palm uniqueness: $e");
      return "حدث خطأ أثناء التحقق من بيانات النخلة.";
    }
  }

  // 💾 حفظ بيانات النخلة مع الفحص
  Future<String?> savePalm(Map<String, dynamic> palmData) async {
    isLoading = true;
    notifyListeners();

    try {
      final farmId = palmData['farm_id'] as int;
      final palmNumber = palmData['palm_number'] as int;
      final rowNumber = palmData['row_number'] as int?;
      final columnNumber = palmData['column_number'] as int?;

      // فحص التكرار قبل الحفظ
      final validationError = await validatePalmUniqueness(
        farmId: farmId,
        palmNumber: palmNumber,
        rowNumber: rowNumber,
        columnNumber: columnNumber,
      );

      if (validationError != null) {
        isLoading = false;
        notifyListeners();
        return validationError; // إرجاع نص الخطأ مباشرة
      }

      // إدراج النخلة عبر DatabaseHelper
      await DatabaseHelper.instance.insertPalm(palmData);

      isLoading = false;
      notifyListeners();
      return null; // نجاح الحفظ
    } catch (e) {
      debugPrint("Error saving palm: $e");
      isLoading = false;
      notifyListeners();
      return "حدث خطأ غير متوقع أثناء الحفظ.";
    }
  }

  // ✏️ تعديل بيانات النخلة مع الفحص
  Future<String?> updatePalm(int palmId, Map<String, dynamic> palmData) async {
    isLoading = true;
    notifyListeners();

    try {
      final farmId = palmData['farm_id'] as int;
      final palmNumber = palmData['palm_number'] as int;
      final rowNumber = palmData['row_number'] as int?;
      final columnNumber = palmData['column_number'] as int?;

      // فحص التكرار قبل الحفظ مع استثناء النخلة الحالية
      final validationError = await validatePalmUniqueness(
        farmId: farmId,
        palmNumber: palmNumber,
        rowNumber: rowNumber,
        columnNumber: columnNumber,
        currentPalmId: palmId,
      );

      if (validationError != null) {
        isLoading = false;
        notifyListeners();
        return validationError; // إرجاع نص الخطأ
      }

      // تحديث بيانات النخلة عبر DatabaseHelper
      await DatabaseHelper.instance.updatePalm(palmId, palmData);

      isLoading = false;
      notifyListeners();
      return null; // نجاح التعديل
    } catch (e) {
      debugPrint("Error updating palm: $e");
      isLoading = false;
      notifyListeners();
      return "حدث خطأ غير متوقع أثناء التعديل.";
    }
  }
}