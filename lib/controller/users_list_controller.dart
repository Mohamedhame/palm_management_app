import 'package:flutter/material.dart';
import 'package:nakeel_demo/routes/add_user.dart';
import 'package:nakeel_demo/services/database_helper.dart';

class UsersListController extends ChangeNotifier {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> get users => _users;

  // 🌟 إضافة خريطة ربط معرّف المستخدم بأسماء مزارعه
  final Map<int, List<String>> _userFarmNamesMap = {};
  Map<int, List<String>> get userFarmNamesMap => _userFarmNamesMap;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await DatabaseHelper.instance.getAllUsers();

      // 🌟 جلب المزارع المخصصة لكل مستخدم ملحق
      _userFarmNamesMap.clear();
      for (var user in _users) {
        final userId = user['id'] as int?;
        if (userId != null) {
          final farms = await DatabaseHelper.instance.getFarmsForUser(userId, false);
          final names = farms.map((f) => f['name'].toString()).toList();
          _userFarmNamesMap[userId] = names;
        }
      }
    } catch (e) {
      _users = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> navigateToAddOrEdit(BuildContext context, [Map<String, dynamic>? user]) async {
    final bool? shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddUser(userToEdit: user),
      ),
    );

    if (shouldRefresh == true) {
      await loadUsers(); // إعادة تحميل البيانات لتحديث الشاشة فوراً
    }
  }

  void showActionMenu(
    BuildContext context,
    TapDownDetails details,
    Map<String, dynamic> user,
  ) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, color: Color(0xFF0288D1)),
              SizedBox(width: 8),
              Text("تعديل البيانات"),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text("حذف المستخدم", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((selectedOption) {
      if (selectedOption == 'edit') {
        navigateToAddOrEdit(context, user);
      } else if (selectedOption == 'delete') {
        confirmDelete(context, user);
      }
    });
  }

  // حوار تأكيد الحذف مع تنفيذ الحذف
  void confirmDelete(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("حذف المستخدم"),
        content: Text("هل أنت تأكد من رغبتك في حذف الحساب (${user['email']})؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteUser(context, user['id']);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // تنفيذ عملية الحذف في قاعدة البيانات
  Future<void> _deleteUser(BuildContext context, int userId) async {
    try {
      await DatabaseHelper.instance.deleteUser(userId);
      await loadUsers(); // إعادة جلب البيانات ليتم تحديث الـ List تلقائياً

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم حذف المستخدم بنجاح"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ أثناء الحذف: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}