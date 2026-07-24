import 'package:flutter/material.dart';
import 'package:nakeel_demo/controller/users_list_controller.dart';
import 'package:provider/provider.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  static const routeName = "/users_show";

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersListController>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<UsersListController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        title: const Text(
          "إدارة المستخدمين والصلاحيات",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0288D1),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<UsersListController>(
        builder: (context, userController, child) {
          if (userController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0288D1)),
              ),
            );
          }

          if (userController.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.supervisor_account_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "لا يوجد مستخدمين مسجلين حالياً",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          final usersList = userController.users;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: usersList.length,
            itemBuilder: (context, index) {
              final user = usersList[index];
              final userId = user['id'] as int;
              final bool isAdmin = user['is_admin'] == 1;
              final bool canAdd = user['can_add'] == 1;

              final farmNames = userController.userFarmNamesMap[userId] ?? [];
              final String farmText = isAdmin
                  ? "كل المزارع"
                  : farmNames.isEmpty
                      ? "لا توجد مزارع مخصصة"
                      : farmNames.join("، ");

              TapDownDetails? tapDetails;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTapDown: (details) => tapDetails = details,
                  onTap: () {
                    if (tapDetails != null) {
                      controller.showActionMenu(context, tapDetails!, user);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isAdmin
                                  ? const Color(0xFFFFE0B2)
                                  : const Color(0xFFE1F5FE),
                              radius: 24,
                              child: Icon(
                                isAdmin
                                    ? Icons.admin_panel_settings_rounded
                                    : Icons.person_rounded,
                                color: isAdmin
                                    ? const Color(0xFFE65100)
                                    : const Color(0xFF0288D1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['email'] as String,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "معرّف الحساب: #$userId",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isAdmin
                                    ? const Color(0xFFE65100)
                                    : const Color(0xFF0288D1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isAdmin ? "مدير" : "موظف",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  canAdd
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  size: 18,
                                  color: canAdd
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  canAdd
                                      ? "مسموح له بالإضافة"
                                      : "قراءة فقط (موقوف الإضافة)",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: canAdd
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.gite_rounded,
                                    size: 18,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      farmText,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.navigateToAddOrEdit(context),
        backgroundColor: const Color(0xFF0288D1),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text(
          "إضافة مستخدم",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}