import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nakeel_demo/routes/home_screen.dart';
import 'package:nakeel_demo/services/database_helper.dart';
import 'package:nakeel_demo/services/shared_prefs_helper.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  String? get errorMessage => _errorMessage;

  void submit(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      bool success = await login(emailController.text, passwordController.text);

      if (success && context.mounted) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم تسجيل الدخول بنجاح!"),
            backgroundColor: Colors.green,
          ),
        );
      } else if (errorMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage!), backgroundColor: Colors.red),
        );
      }
    }
  }

  // تغيير رؤية كلمة المرور
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // دالة تسجيل الدخول
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userMap = await DatabaseHelper.instance.getUserByEmail(
        email.trim(),
      );

      if (userMap == null) {
        _errorMessage = "البريد الإلكتروني غير مسجل لدينا";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (userMap["password"] != password) {
        _errorMessage = "كلمة المرور التي أدخلتها غير صحيحة";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      SharedPrefsHelper.saveString("user", jsonEncode(userMap));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "حدث خطأ غير متوقع، يرجى المحاولة لاحقاً";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
