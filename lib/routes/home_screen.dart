import 'package:flutter/material.dart';
import 'package:nakeel_demo/controller/main_provider.dart';
import 'package:nakeel_demo/models/users_models.dart';
import 'package:nakeel_demo/routes/barcode_scanner_screen.dart';
import 'package:nakeel_demo/routes/control_panel.dart';
import 'package:nakeel_demo/routes/login_screen.dart';
import 'package:nakeel_demo/routes/palms_grid_screen.dart';
import 'package:nakeel_demo/routes/palms_list_screen.dart';
import 'package:nakeel_demo/services/shared_prefs_helper.dart';
import 'package:nakeel_demo/widgets/build_menu_card.dart';
import 'package:nakeel_demo/widgets/welcome_by_user.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const routeName = "/home_screen";

  @override
  Widget build(BuildContext context) {
    final mainProvider = Provider.of<MainProvider>(context);
    final userData = mainProvider.getUserData();
    final UserModel user = UserModel.fromMap(userData);
    final bool isAdmin = user.isAdmin == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        title: const Text(
          "نظام إدارة النخيل",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WelcomeByUser(isAdmin: isAdmin, user: user),
              const SizedBox(height: 30),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    // 1. زر التقاط الباركود
                    BuildMenuCard(
                      icon: Icons.qr_code_scanner_rounded,
                      title: "مسح الباركود",
                      color: const Color(0xFF2E7D32),
                      onTap: () {
                        // print("فتح الكاميرا للمسح");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BarcodeScannerScreen(),
                          ),
                        );
                      },
                    ),

                    BuildMenuCard(
                      icon: Icons.forest_rounded,
                      title: "بيانات النخيل",
                      color: const Color(0xFF43A047),
                      onTap: () {
                        Navigator.pushNamed(context, PalmsListScreen.routeName);
                      },
                    ),
                  ],
                ),
              ),
              BuildMenuCard(
                icon: Icons.airplay_sharp,
                title: "لوحة النخيل",
                color: const Color(0xFF43A047),
                onTap: () {
                  Navigator.pushNamed(context, PalmsGridScreen.routeName);
                },
              ),
              const SizedBox(height: 20),
              if (isAdmin)
                BuildMenuCard(
                  icon: Icons.dashboard_customize_rounded,
                  title: "لوحة التحكم",
                  color: const Color(0xFFE65100), // لون برتقالي مميز للإدارة
                  onTap: () {
                    Navigator.of(context).pushNamed(ControlPanel.routeName);
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await SharedPrefsHelper.clearAll();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      LoginScreen.routeName,
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  "تسجيل الخروج",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
