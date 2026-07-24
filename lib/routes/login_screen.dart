import 'package:flutter/material.dart';
import 'package:nakeel_demo/controller/AuthProvider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const routeName = "/login_screen";

  @override
  Widget build(BuildContext context) {
    // الاستماع للتغيرات في الـ AuthProvider (مثل حالة التحميل وإظهار الباسورد)
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.nature_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "مرحباً بك مجدداً",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),

                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: authProvider.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "تسجيل الدخول",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // حقل الإيميل
                              TextFormField(
                                controller: authProvider.emailController,
                                keyboardType: TextInputType.emailAddress,
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.left,
                                decoration: InputDecoration(
                                  labelText: "البريد الإلكتروني",
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "الرجاء إدخال البريد الإلكتروني";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // حقل كلمة المرور
                              TextFormField(
                                controller: authProvider.passwordController,
                                obscureText:
                                    !authProvider
                                        .isPasswordVisible, // يقرأ مباشرة من الـ Provider
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.left,
                                decoration: InputDecoration(
                                  labelText: "كلمة المرور",
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      authProvider.isPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey,
                                    ),
                                    onPressed:
                                        () =>
                                            authProvider
                                                .togglePasswordVisibility(), // استدعاء الأكشن من الـ Provider
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "الرجاء إدخال كلمة المرور";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // زر الدخول المتفاعل مع حالة التحميل
                              authProvider.isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF2E7D32),
                                    ),
                                  )
                                  : ElevatedButton(
                                    onPressed: () => authProvider.submit(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "دخول",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
