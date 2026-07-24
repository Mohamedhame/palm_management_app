import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nakeel_demo/controller/network_provider.dart';
import 'package:nakeel_demo/routes/home_screen.dart';
import 'package:nakeel_demo/routes/login_screen.dart';
import 'package:nakeel_demo/routes/no_internet.dart';
import 'package:nakeel_demo/services/shared_prefs_helper.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const routeName = "/splash_screen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startAppFlow();
  }

  Future<void> _startAppFlow() async {
    // 1. تشغيل الفحص الانتظاري والانتظار الجمالي معاً في نفس الوقت
    final networkFuture = context.read<NetworkProvider>().checkConnection();
    final timerFuture = Future.delayed(const Duration(seconds: 2));

    // الانتظار حتى ينتهي الاثنان معاً
    final results = await Future.wait([networkFuture, timerFuture]);
    final bool isConnected = results[0] as bool;

    if (!mounted) return;

    // 2. إذا لا يوجد إنترنت -> توجيه لصفحة عدم وجود إنترنت
    if (!isConnected) {
      Navigator.of(context).pushReplacementNamed(NoInternet.routeName);
      return;
    }

    // 3. إذا يوجد إنترنت -> فحص تسجيل الدخول
    String userMap = SharedPrefsHelper.getString("user");
    if (userMap.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.nature_rounded,
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "إدارة النخيل",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "نظام ذكي لمتابعة ورعاية المزارع",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const Spacer(flex: 2),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}