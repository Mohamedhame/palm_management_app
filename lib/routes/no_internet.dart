import 'package:flutter/material.dart';
import 'package:nakeel_demo/controller/network_provider.dart';
import 'package:nakeel_demo/routes/home_screen.dart';
import 'package:nakeel_demo/routes/login_screen.dart';
import 'package:nakeel_demo/services/shared_prefs_helper.dart';
import 'package:provider/provider.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({super.key});
  static const routeName = "/no_internet";

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  bool _isRetrying = false;

  void _navigateIfConnected(bool isConnected) {
    if (!isConnected || !mounted) return;

    // التأكد من تنفيذ التوجيه بعد انتهاء مرحلة الـ Build لمنع أخطاء Flutter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final String userMap = SharedPrefsHelper.getString("user");
      if (userMap.isNotEmpty) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      }
    });
  }

  Future<void> _handleRetry() async {
    setState(() => _isRetrying = true);
    
    final netProvider = context.read<NetworkProvider>();
    final isConnected = await netProvider.checkConnection();

    if (mounted) {
      setState(() => _isRetrying = false);
      
      if (isConnected) {
        _navigateIfConnected(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("لا يزال الاتصال مقطوعاً، حاول مرة أخرى"),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // الاستماع التلقائي لعودة الإنترنت عبر الخلفية
    final isConnected = context.select<NetworkProvider, bool>((net) => net.hasConnection);
    _navigateIfConnected(isConnected);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // أيقونة متناسقة مع طبيعة التطبيق والشبكة
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 70,
                    color: Colors.red[400],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const Text(
                "لا يوجد اتصال بالإنترنت",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                "تعذر الاتصال بالشبكة. يرجى التحقق من إعدادات Wi-Fi أو بيانات الهاتف وإعادة المحاولة.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // زر إعادة المحاولة Tries
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isRetrying ? null : _handleRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _isRetrying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "إعادة المحاولة",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}