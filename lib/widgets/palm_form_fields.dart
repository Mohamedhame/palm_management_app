import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nakeel_demo/controller/add_palm_controller.dart';
import 'package:nakeel_demo/widgets/palm_date_picker_tile.dart';

class PalmFormFields extends StatelessWidget {
  final TextEditingController palmNumberController;
  final TextEditingController typeController;
  final TextEditingController rowNumberController;
  final TextEditingController columnNumberController;
  final TextEditingController sourceController;

  final ValueNotifier<String?> selectedFarmIdNotifier;
  final ValueNotifier<String> healthStatusNotifier;
  final ValueNotifier<String> productionStatusNotifier;

  final ValueNotifier<DateTime?> plantingDateNotifier;
  final ValueNotifier<DateTime?> lastFertilizationDateNotifier;
  final ValueNotifier<DateTime?> lastIrrigationDateNotifier;
  final ValueNotifier<DateTime?> lastHarvestDateNotifier;

  const PalmFormFields({
    super.key,
    required this.palmNumberController,
    required this.typeController,
    required this.rowNumberController,
    required this.columnNumberController,
    required this.sourceController,
    required this.selectedFarmIdNotifier,
    required this.healthStatusNotifier,
    required this.productionStatusNotifier,
    required this.plantingDateNotifier,
    required this.lastFertilizationDateNotifier,
    required this.lastIrrigationDateNotifier,
    required this.lastHarvestDateNotifier,
  });

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  InputDecoration _buildInputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _buildInputDecoration(icon).copyWith(labelText: label),
      validator: (val) {
        if (label.contains('*') && (val == null || val.trim().isEmpty)) {
          return "هذا الحقل مطلوب";
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("تحديد المزرعة *"),
        const SizedBox(height: 12),
        Consumer<AddPalmController>(
          builder: (context, controller, child) {
            return ValueListenableBuilder<String?>(
              valueListenable: selectedFarmIdNotifier,
              builder: (context, selectedId, child) {
                return DropdownButtonFormField<String>(
                  value: selectedId,
                  hint: const Text("اختر المزرعة التابعة لها النخلة"),
                  items:
                      controller.farms.map((farm) {
                        return DropdownMenuItem<String>(
                          value: farm['id'].toString(),
                          child: Text(farm['name'] as String),
                        );
                      }).toList(),
                  onChanged: (val) => selectedFarmIdNotifier.value = val,
                  decoration: _buildInputDecoration(Icons.agriculture_rounded),
                  validator: (val) => val == null ? "يرجى اختيار المزرعة" : null,
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),

        _buildSectionTitle("المعلومات الأساسية"),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: palmNumberController,
                label: "رقم النخلة *",
                icon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: typeController,
                label: "النوع (مثل: مجدول)",
                icon: Icons.category_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildSectionTitle("الموقع بالشبكة"),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: rowNumberController,
                label: "رقم الصف",
                icon: Icons.table_rows_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: columnNumberController,
                label: "رقم العمود",
                icon: Icons.view_column_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildSectionTitle("الحالة والنمو"),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: healthStatusNotifier,
                builder: (context, value, child) {
                  return DropdownButtonFormField<String>(
                    value: value,
                    items: const [
                      DropdownMenuItem(
                        value: 'healthy',
                        child: Text("سليمة 🟢"),
                      ),
                      DropdownMenuItem(
                        value: 'infected',
                        child: Text("مصابة 🔴"),
                      ),
                      DropdownMenuItem(
                        value: 'warning',
                        child: Text("ملاحظة 🟡"),
                      ),
                    ],
                    onChanged: (val) => healthStatusNotifier.value = val!,
                    decoration: _buildInputDecoration(
                      Icons.health_and_safety_rounded,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: productionStatusNotifier,
                builder: (context, value, child) {
                  return DropdownButtonFormField<String>(
                    value: value,
                    items: const [
                      DropdownMenuItem(
                        value: 'baby',
                        child: Text("فسيلة"),
                      ),
                      DropdownMenuItem(
                        value: 'producing',
                        child: Text("مثمرة"),
                      ),
                      DropdownMenuItem(
                        value: 'stopped',
                        child: Text("متوقفة"),
                      ),
                    ],
                    onChanged: (val) => productionStatusNotifier.value = val!,
                    decoration: _buildInputDecoration(Icons.eco_rounded),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: sourceController,
          label: "مصدر/أصل النخلة",
          icon: Icons.place_rounded,
        ),
        const SizedBox(height: 16),

        _buildSectionTitle("التواريخ والعمليات الزراعية"),
        const SizedBox(height: 12),

        PalmDatePickerTile(
          title: "تاريخ الغرس",
          notifier: plantingDateNotifier,
        ),
        PalmDatePickerTile(
          title: "تاريخ آخر تسميد",
          notifier: lastFertilizationDateNotifier,
        ),
        PalmDatePickerTile(
          title: "تاريخ آخر ري",
          notifier: lastIrrigationDateNotifier,
        ),
        PalmDatePickerTile(
          title: "تاريخ آخر حصاد",
          notifier: lastHarvestDateNotifier,
        ),
      ],
    );
  }
}