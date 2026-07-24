import 'package:flutter/material.dart';
import 'package:nakeel_demo/controller/farms_controller.dart';
import 'package:nakeel_demo/widgets/build_text_field.dart';
import 'package:provider/provider.dart';

class AddFarmScreen extends StatefulWidget {
  final Map<String, dynamic>? farmToEdit;

  const AddFarmScreen({super.key, this.farmToEdit});

  static const routeName = "/new_farm";

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _areaController;
  late TextEditingController _spacingController;
  late TextEditingController _notesController;

  bool get _isEditing => widget.farmToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.farmToEdit?['name'] ?? '',
    );
    _locationController = TextEditingController(
      text: widget.farmToEdit?['location'] ?? '',
    );
    _areaController = TextEditingController(
      text: widget.farmToEdit?['area_in_acres']?.toString() ?? '',
    );
    _spacingController = TextEditingController(
      text: widget.farmToEdit?['palm_spacing']?.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.farmToEdit?['notes'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _spacingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final success = await context.read<FarmsController>().saveFarm(
      formKey: _formKey,
      name: _nameController.text,
      location: _locationController.text,
      area: _areaController.text,
      spacing: _spacingController.text,
      notes: _notesController.text,
      farmToEdit: widget.farmToEdit,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? "تم تعديل المزرعة بنجاح" : "تم حفظ المزرعة بنجاح",
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        title: Text(
          _isEditing ? "تعديل بيانات المزرعة" : "إضافة مزرعة جديدة",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8D6E63),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                BuildTextField(
                  controller: _nameController,
                  label: "اسم المزرعة",
                  hint: "مثال: مزرعة النخيل الشمالية",
                  icon: Icons.gite_rounded,
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? "يرجى إدخال اسم المزرعة"
                              : null,
                ),
                const SizedBox(height: 16),

                BuildTextField(
                  controller: _locationController,
                  label: "الموقع الجغرافي / العنوان",
                  hint: "مثال: طريق الاسكندرية الصحراوي، الكيلو 50",
                  icon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: BuildTextField(
                        controller: _areaController,
                        label: "المساحة (بالمتر مربع)",
                        hint: "0.0",
                        icon: Icons.square_foot_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: BuildTextField(
                        controller: _spacingController,
                        label: "مسافة التباعد (متر)",
                        hint: "مثال: 8",
                        icon: Icons.space_bar_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                BuildTextField(
                  controller: _notesController,
                  label: "ملاحظات إضافية",
                  hint: "أي تفاصيل أخرى حول التربة، الصنف الغالب، إلخ...",
                  icon: Icons.note_alt_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: Icon(
                    _isEditing ? Icons.edit_rounded : Icons.save_rounded,
                  ),
                  label: Text(
                    _isEditing
                        ? "تحديث بيانات المزرعة"
                        : "حفظ المزرعة في النظام",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D6E63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
