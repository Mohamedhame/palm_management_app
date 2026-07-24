import 'package:flutter/material.dart';
import 'package:nakeel_demo/routes/add_palm_screen.dart';
import 'package:nakeel_demo/routes/manage_farms.dart';
import 'package:nakeel_demo/routes/users_list_screen.dart';
import 'package:nakeel_demo/widgets/build_admin_option_card.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  static const routeName = "/control_panel";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        title: const Text(
          "لوحة التحكم والإشراف",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "مرحباً بك في وحدة الإدارة. يرجى اختيار الإجراء المطلوب",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 90),

              BuildAdminOptionCard(
                icon: Icons.add_circle_outline_rounded,
                title: "إضافة نخلة جديدة",
                subtitle: "تسجيل نخلة جديدة في النظام وتوليد بياناتها",
                color: const Color(0xFF2E7D32),
                onTap: () {
                  Navigator.pushNamed(context, AddPalmScreen.routeName);
                },
              ),

              const SizedBox(height: 16),

              BuildAdminOptionCard(
                icon: Icons.supervisor_account_rounded,
                title: "عرض المستخدمين والصلاحيات",
                subtitle: "إدارة حسابات الموظفين والمشرفين في المزرعة",
                color: const Color(0xFF0288D1),
                onTap: () {
                  Navigator.pushNamed(context, UsersListScreen.routeName);
                },
              ),

              BuildAdminOptionCard(
                icon: Icons.holiday_village_rounded,
                title: "عرض وإدارة المزارع",
                subtitle:
                    "متابعة المزارع المسجلة، تعديل بياناتها، أو الاطلاع على إحصائياتها",
                color: const Color(0xFF4CAF50),
                onTap: () {
                  Navigator.pushNamed(context, ManageFarms.routeName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
