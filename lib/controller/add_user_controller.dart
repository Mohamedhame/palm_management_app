import 'package:flutter/material.dart';
import 'package:nakeel_demo/services/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddUserController extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final SupabaseClient _client = Supabase.instance.client;

  bool isEditMode = false;
  int? editingUserId;

  bool isAdmin = false;
  bool canAdd = true;
  bool isAllFarms = true;

  bool isLoadingFarms = false;
  List<Map<String, dynamic>> farms = [];
  bool _isShowPassword = true;
  bool get isShowPassword => _isShowPassword;

  // قائمة تخزين معرّفات المزارع المحددة بدلاً من مزرعة واحدة
  final Set<int> selectedFarmIds = {};

  void initializeData(Map<String, dynamic>? userToEdit) async {
    if (userToEdit != null) {
      isEditMode = true;
      editingUserId = userToEdit['id'] as int;
      emailController.text = userToEdit['email'] ?? '';
      passwordController.text = userToEdit['password'] ?? '';
      isAdmin = userToEdit['is_admin'] == 1;
      canAdd = userToEdit['can_add'] == 1;

      // جلب المزارع المخصصة لهذا المستخدم
      if (editingUserId != null) {
        final userFarms = await DatabaseHelper.instance.getFarmsForUser(
          editingUserId!,
          false,
        );
        selectedFarmIds.clear();
        for (var farm in userFarms) {
          if (farm['id'] != null) {
            selectedFarmIds.add(farm['id'] as int);
          }
        }
        isAllFarms =
            selectedFarmIds.isEmpty && !isAdmin
                ? false
                : (isAdmin || selectedFarmIds.isEmpty);
        notifyListeners();
      }
    }
  }

  Future<void> loadFarms() async {
    isLoadingFarms = true;
    notifyListeners();

    try {
      farms = await DatabaseHelper.instance.getAllFarms();
    } catch (e) {
      farms = [];
    }

    isLoadingFarms = false;
    notifyListeners();
  }

  void toggleAdmin(bool val) {
    isAdmin = val;
    if (isAdmin) {
      canAdd = true;
      isAllFarms = true;
      selectedFarmIds.clear();
    }
    notifyListeners();
  }

  void toggleCanAdd(bool val) {
    canAdd = val;
    notifyListeners();
  }

  void toggleFarmScope(bool allFarms) {
    isAllFarms = allFarms;
    if (isAllFarms) {
      selectedFarmIds.clear();
    }
    notifyListeners();
  }

  void toggleFarmSelection(int farmId, bool isSelected) {
    if (isSelected) {
      selectedFarmIds.add(farmId);
    } else {
      selectedFarmIds.remove(farmId);
    }
    notifyListeners();
  }

  Future<bool> saveUser() async {
    if (!formKey.currentState!.validate()) return false;

    // التحقق من تحديد مزرعة واحدة على الأقل إذا لم يكن الخيار "كل المزارع" أو "مدير"
    if (!isAllFarms && !isAdmin && selectedFarmIds.isEmpty) {
      return false;
    }

    try {
      final userData = {
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'is_admin': isAdmin ? 1 : 0,
        'can_add': isAdmin ? 1 : (canAdd ? 1 : 0),
        'farm_id': selectedFarmIds.isNotEmpty ? selectedFarmIds.first : null,
        'created_at': DateTime.now().toIso8601String(),
      };

      int userId;
      if (isEditMode && editingUserId != null) {
        await DatabaseHelper.instance.updateUser(editingUserId!, userData);
        userId = editingUserId!;
      } else {
        userId = await DatabaseHelper.instance.insertUser(userData);
      }

      // تحديث جدول الربط user_farms
      if (!isAdmin && !isAllFarms) {
        // حذف التعيينات القديمة من Supabase
        await _client.from('user_farms').delete().eq('user_id', userId);

        // إعادة إضافة المزارع المختارة
        for (int farmId in selectedFarmIds) {
          await DatabaseHelper.instance.assignUserToFarm(userId, farmId);
        }
      } else if (isAdmin || isAllFarms) {
        // إذا أصبح مديراً أو تم منحه كل المزارع يتم إزالة التخصيصات المحددة
        await _client.from('user_farms').delete().eq('user_id', userId);
      }

      return true;
    } catch (e) {
      debugPrint("Error saving user: $e");
      return false;
    }
  }

  void togglePassword() {
    _isShowPassword = !_isShowPassword;
    notifyListeners();
  }

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }
}