import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  final SupabaseClient _client = Supabase.instance.client;

  DatabaseHelper._init();

  // ==========================================
  // 1. عمليات جدول المزارع (FARMS CRUD)
  // ==========================================

  Future<int> insertFarm(Map<String, dynamic> farmData) async {
    final response =
        await _client.from('farms').insert(farmData).select('id').single();
    return response['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getAllFarms() async {
    // جلب المزارع مع ربط جدول الربط user_farms وجدول النخيل palms
    final List<dynamic> farms = await _client
        .from('farms')
        .select('*, user_farms(user_id), palms(id)')
        .order('name', ascending: true);

    return farms.map((farm) {
      final map = Map<String, dynamic>.from(farm);

      final employeesList = map['user_farms'] as List? ?? [];
      final palmsList = map['palms'] as List? ?? [];

      map['total_employees'] = employeesList
          .length; // حساب عدد العمال المسندين للمزرعة من جدول الربط
      map['total_palms'] = palmsList.length;

      map.remove('user_farms');
      map.remove('palms');

      return map;
    }).toList();
  }

  Future<Map<String, dynamic>?> getFarmById(int id) async {
    final response =
        await _client.from('farms').select().eq('id', id).maybeSingle();
    return response;
  }

  Future<int> updateFarm(int id, Map<String, dynamic> farmData) async {
    await _client.from('farms').update(farmData).eq('id', id);
    return 1;
  }

  Future<int> deleteFarm(int id) async {
    await _client.from('farms').delete().eq('id', id);
    return 1;
  }

  // ==========================================
  // 2. عمليات جدول المستخدمين والمزارع (USERS & USER_FARMS CRUD)
  // ==========================================

  Future<int> insertUser(Map<String, dynamic> userData) async {
    final response =
        await _client.from('users').insert(userData).select('id').single();
    return response['id'] as int;
  }

  // ربط موظف بمزرعة معينة
  Future<int> assignUserToFarm(int userId, int farmId) async {
    final response = await _client
        .from('user_farms')
        .insert({'user_id': userId, 'farm_id': farmId})
        .select('id')
        .single();
    return response['id'] as int;
  }

  // جلب كافة المزارع الخاصة بمستخدم معين
  Future<List<Map<String, dynamic>>> getFarmsForUser(
    int userId,
    bool isAdmin,
  ) async {
    if (isAdmin) {
      final List<dynamic> response =
          await _client.from('farms').select().order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } else {
      // جلب بيانات المستخدم لمعرفة farm_id الفرادي إن وجد
      final user = await getUserById(userId);
      final defaultFarmId = user?['farm_id'];

      // جلب مزارع جدول الربط user_farms
      final List<dynamic> userFarms = await _client
          .from('user_farms')
          .select('farm_id')
          .eq('user_id', userId);

      final List<int> farmIds =
          userFarms.map((uf) => uf['farm_id'] as int).toList();

      if (defaultFarmId != null && !farmIds.contains(defaultFarmId)) {
        farmIds.add(defaultFarmId as int);
      }

      if (farmIds.isEmpty) return [];

      final List<dynamic> farms = await _client
          .from('farms')
          .select()
          .inFilter('id', farmIds)
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(farms);
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final List<dynamic> response = await _client.from('users').select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final response =
        await _client.from('users').select().eq('id', id).maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final response =
        await _client.from('users').select().eq('email', email).maybeSingle();
    return response;
  }

  Future<int> updateUser(int id, Map<String, dynamic> userData) async {
    await _client.from('users').update(userData).eq('id', id);
    return 1;
  }

  Future<int> deleteUser(int id) async {
    await _client.from('users').delete().eq('id', id);
    return 1;
  }

  // ==========================================
  // 3. عمليات جدول النخيل (PALMS CRUD)
  // ==========================================

  Future<int> insertPalm(Map<String, dynamic> palmData) async {
    final response =
        await _client.from('palms').insert(palmData).select('id').single();
    return response['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getAllPalms() async {
    final List<dynamic> response = await _client
        .from('palms')
        .select()
        .order('row_number', ascending: true)
        .order('column_number', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getPalmsByFarm(int farmId) async {
    final List<dynamic> response = await _client
        .from('palms')
        .select()
        .eq('farm_id', farmId)
        .order('row_number', ascending: true)
        .order('column_number', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getPalmById(int id) async {
    final response =
        await _client.from('palms').select().eq('id', id).maybeSingle();
    return response;
  }

  Future<int> updatePalm(int id, Map<String, dynamic> palmData) async {
    await _client.from('palms').update(palmData).eq('id', id);
    return 1;
  }

  Future<int> deletePalm(int id) async {
    await _client.from('palms').delete().eq('id', id);
    return 1;
  }

  Future<void> close() async {
    // Supabase يربط عبر HTTP/WebSockets ولا يتطلب دالة إغلاق يدوية
  }
}
