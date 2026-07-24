import 'package:flutter/material.dart';
import 'package:nakeel_demo/models/users_models.dart';

class WelcomeByUser extends StatelessWidget {
  const WelcomeByUser({
    super.key,
    required this.isAdmin,
    required this.user,
  });

  final bool isAdmin;
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE8F5E9),
              radius: 28,
              child: Icon(
                isAdmin
                    ? Icons.admin_panel_settings
                    : Icons.person_outline,
                color: const Color(0xFF2E7D32),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "مرحباً بك، ${user.email.split('@')[0]}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAdmin
                      ? "صلاحية: مدير النظام"
                      : "صلاحية: موظف ميداني",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}