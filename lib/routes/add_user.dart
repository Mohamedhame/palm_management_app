import 'package:flutter/material.dart';
import 'package:nakeel_demo/controller/add_user_controller.dart';
import 'package:provider/provider.dart';

class AddUser extends StatefulWidget {
  final Map<String, dynamic>? userToEdit;

  const AddUser({super.key, this.userToEdit});

  static const routeName = "/add_user";

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final AddUserController _controller = AddUserController();

  @override
  void initState() {
    super.initState();
    _controller.initializeData(widget.userToEdit);
    _controller.loadFarms();
  }

  @override
  void dispose() {
    _controller.disposeControllers();
    _controller.dispose();
    super.dispose();
  }

  void _onSavePressed() async {
    // التحقق أولاً من صحة الحقول الإجبارية للنموذج (البريد وكلمة المرور)
    if (!(_controller.formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_controller.isAllFarms &&
        !_controller.isAdmin &&
        _controller.selectedFarmIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى اختيار مزرعة واحدة على الأقل للموظف"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await _controller.saveUser();
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _controller.isEditMode
                  ? "تم تعديل البيانات بنجاح"
                  : "تم إضافة المستخدم بنجاح",
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("حدث خطأ أثناء حفظ البيانات"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        title: Text(
          _controller.isEditMode
              ? "تعديل بيانات المستخدم"
              : "إضافة مستخدم جديد",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0288D1),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("البيانات الأساسية"),
              const SizedBox(height: 12),

              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.left,
                        decoration: _buildInputDecoration(
                          label: "البريد الإلكتروني",
                          icon: Icons.email_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty)
                            return "الرجاء إدخال البريد الإلكتروني";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Selector<AddUserController, bool>(
                        builder: (context, value, child) {
                          return TextFormField(
                            controller: _controller.passwordController,
                            obscureText: value,
                            textAlign: TextAlign.left,
                            decoration: _buildInputDecoration(
                              label: "كلمة المرور",
                              icon: Icons.lock_rounded,
                              isPassword: true,
                              onPressed: () {
                                context
                                    .read<AddUserController>()
                                    .togglePassword();
                              },
                            ),
                            validator: (value) {
                              // 👈 أصبحت كلمة المرور إجبارية دائماً في كل الحالات (إضافة أو تعديل)
                              if (value == null || value.trim().isEmpty) {
                                return "الرجاء إدخال كلمة المرور";
                              }
                              return null;
                            },
                          );
                        },
                        selector: (p0, p1) => p1.isShowPassword,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("الأدوار والصلاحيات"),
              const SizedBox(height: 12),

              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text(
                              "حساب مدير (Admin)",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              "يمنح المستخدم كامل الصلاحيات لإدارة جميع المزارع",
                            ),
                            activeColor: const Color(0xFFE65100),
                            value: _controller.isAdmin,
                            onChanged: _controller.toggleAdmin,
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text("السماح بالإصافة والتعديل"),
                            subtitle: const Text(
                              "إذا تم إيقافه سيكون الحساب للقراءة فقط",
                            ),
                            activeColor: const Color(0xFF0288D1),
                            value: _controller.canAdd,
                            onChanged:
                                _controller.isAdmin
                                    ? null
                                    : _controller.toggleCanAdd,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("نطاق العمل (المزارع)"),
              const SizedBox(height: 12),

              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text("كل المزارع"),
                                  value: true,
                                  groupValue: _controller.isAllFarms,
                                  activeColor: const Color(0xFF0288D1),
                                  onChanged:
                                      _controller.isAdmin
                                          ? null
                                          : (val) =>
                                              _controller.toggleFarmScope(val!),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text("مزارع محددة"),
                                  value: false,
                                  groupValue: _controller.isAllFarms,
                                  activeColor: const Color(0xFF0288D1),
                                  onChanged:
                                      _controller.isAdmin
                                          ? null
                                          : (val) =>
                                              _controller.toggleFarmScope(val!),
                                ),
                              ),
                            ],
                          ),

                          if (!_controller.isAllFarms &&
                              !_controller.isAdmin) ...[
                            const Divider(),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              child: Text(
                                "اختر المزارع المسموح للموظف بإدارتها:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (_controller.isLoadingFarms)
                              const Center(child: CircularProgressIndicator())
                            else if (_controller.farms.isEmpty)
                              const Text(
                                "لا توجد مزارع مسجلة بالنظام لربطها بالحساب",
                                style: TextStyle(color: Colors.red),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _controller.farms.length,
                                itemBuilder: (context, index) {
                                  final farm = _controller.farms[index];
                                  final farmId = farm['id'] as int;
                                  final isSelected = _controller.selectedFarmIds
                                      .contains(farmId);

                                  return CheckboxListTile(
                                    activeColor: const Color(0xFF0288D1),
                                    title: Text(
                                      "مزرعة: ${farm['name'] ?? 'بدون اسم'}",
                                    ),
                                    subtitle: Text("معرّف المزرعة: #$farmId"),
                                    value: isSelected,
                                    onChanged: (bool? checked) {
                                      _controller.toggleFarmSelection(
                                        farmId,
                                        checked ?? false,
                                      );
                                    },
                                  );
                                },
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _onSavePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0288D1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  icon: Icon(
                    _controller.isEditMode
                        ? Icons.edit_note_rounded
                        : Icons.save_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    _controller.isEditMode
                        ? "تعديل حساب المستخدم"
                        : "حفظ حساب المستخدم",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    bool isPassword = false,
    IconData iconPass = Icons.remove_red_eye,
    void Function()? onPressed,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF0288D1)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0288D1), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      suffixIcon:
          isPassword
              ? IconButton(onPressed: onPressed, icon: Icon(iconPass))
              : null,
    );
  }
}
