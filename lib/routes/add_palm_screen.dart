import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nakeel_demo/controller/add_palm_controller.dart';
import 'package:nakeel_demo/widgets/barcode_dialog.dart';
import 'package:nakeel_demo/widgets/palm_form_fields.dart';

class AddPalmScreen extends StatefulWidget {
  final String? initialFarmId;
  final Map<String, dynamic>? palmData;

  const AddPalmScreen({super.key, this.initialFarmId, this.palmData});

  static const routeName = "/add_palm";

  @override
  State<AddPalmScreen> createState() => _AddPalmScreenState();
}

class _AddPalmScreenState extends State<AddPalmScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _palmNumberController;
  late final TextEditingController _typeController;
  late final TextEditingController _rowNumberController;
  late final TextEditingController _columnNumberController;
  late final TextEditingController _sourceController;

  late final ValueNotifier<String?> _selectedFarmIdNotifier;
  late final ValueNotifier<String> _healthStatusNotifier;
  late final ValueNotifier<String> _productionStatusNotifier;

  late final ValueNotifier<DateTime?> _plantingDateNotifier;
  late final ValueNotifier<DateTime?> _lastFertilizationDateNotifier;
  late final ValueNotifier<DateTime?> _lastIrrigationDateNotifier;
  late final ValueNotifier<DateTime?> _lastHarvestDateNotifier;

  bool get isEditing => widget.palmData != null;

  void handelInputs(Map<String, dynamic>? p) {
    _palmNumberController = TextEditingController(
      text: p?['palm_number']?.toString() ?? '',
    );
    _typeController = TextEditingController(text: p?['type']?.toString() ?? '');
    _rowNumberController = TextEditingController(
      text: p?['row_number']?.toString() ?? '',
    );
    _columnNumberController = TextEditingController(
      text: p?['column_number']?.toString() ?? '',
    );
    _sourceController = TextEditingController(
      text: p?['source']?.toString() ?? '',
    );

    _selectedFarmIdNotifier = ValueNotifier(
      p?['farm_id']?.toString() ?? widget.initialFarmId,
    );
    _healthStatusNotifier = ValueNotifier(p?['health_status'] ?? 'healthy');
    _productionStatusNotifier = ValueNotifier(
      p?['production_status'] ?? 'baby',
    );

    _plantingDateNotifier = ValueNotifier(_parseDate(p?['planting_date']));
    _lastFertilizationDateNotifier = ValueNotifier(
      _parseDate(p?['last_fertilization_date']),
    );
    _lastIrrigationDateNotifier = ValueNotifier(
      _parseDate(p?['last_irrigation_date']),
    );
    _lastHarvestDateNotifier = ValueNotifier(
      _parseDate(p?['last_harvest_date']),
    );
  }

  @override
  void initState() {
    super.initState();
    handelInputs(widget.palmData);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddPalmController>().fetchFarms();
    });
  }

  DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return null;
    return DateTime.tryParse(dateStr.toString());
  }

  @override
  void dispose() {
    _palmNumberController.dispose();
    _typeController.dispose();
    _rowNumberController.dispose();
    _columnNumberController.dispose();
    _sourceController.dispose();
    _selectedFarmIdNotifier.dispose();
    _healthStatusNotifier.dispose();
    _productionStatusNotifier.dispose();
    _plantingDateNotifier.dispose();
    _lastFertilizationDateNotifier.dispose();
    _lastIrrigationDateNotifier.dispose();
    _lastHarvestDateNotifier.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<AddPalmController>();

    final int palmNumber = int.parse(_palmNumberController.text.trim());
    final int? rowNumber =
        _rowNumberController.text.isEmpty
            ? null
            : int.parse(_rowNumberController.text.trim());
    final int? columnNumber =
        _columnNumberController.text.isEmpty
            ? null
            : int.parse(_columnNumberController.text.trim());

    final Map<String, dynamic> palmData = {
      'palm_number': palmNumber,
      'type': _typeController.text.trim(),
      'row_number': rowNumber,
      'column_number': columnNumber,
      'health_status': _healthStatusNotifier.value,
      'production_status': _productionStatusNotifier.value,
      'source': _sourceController.text.trim(),
      'farm_id':
          _selectedFarmIdNotifier.value != null
              ? int.tryParse(_selectedFarmIdNotifier.value!)
              : null,
      'planting_date': _plantingDateNotifier.value?.toIso8601String(),
      'last_fertilization_date':
          _lastFertilizationDateNotifier.value?.toIso8601String(),
      'last_irrigation_date':
          _lastIrrigationDateNotifier.value?.toIso8601String(),
      'last_harvest_date': _lastHarvestDateNotifier.value?.toIso8601String(),
      'created_at':
          isEditing
              ? widget.palmData!['created_at']
              : DateTime.now().toIso8601String(),
    };

    String? errorMessage;
    if (isEditing) {
      final palmId = widget.palmData!['id'] as int;
      errorMessage = await controller.updatePalm(palmId, palmData);
    } else {
      errorMessage = await controller.savePalm(palmData);
    }

    if (context.mounted) {
      if (errorMessage == null) {
        final String farmIdStr = _selectedFarmIdNotifier.value ?? '0';
        final String rowStr = rowNumber?.toString() ?? '0';
        final String colStr = columnNumber?.toString() ?? '0';
        final String barcodeData =
            "farm-$farmIdStr-palm-$palmNumber-row-$rowStr-col-$colStr";
        await BarcodeDialog.show(
          context,
          barcodeData: barcodeData,
          palmNumber: palmNumber,
        );

        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red[800],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          isEditing ? "تعديل بيانات النخلة" : "إضافة نخلة جديدة",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<AddPalmController>(
        builder: (context, controller, child) {
          // 1. حالة التحميل
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            );
          }

          // 2. حالة عدم وجود أي مزرعة
          if (controller.farms.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.agriculture_outlined,
                      size: 80,
                      color: Colors.amber[800],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "لا توجد مزارع مسجلة!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "يجب إضافة مزرعة واحدة على الأقل قبل البدء في تسجيل النخيل.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text(
                        "الرجوع",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          // 3. عرض النموذج الطبيعي في حالة وجود مزارع
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PalmFormFields(
                    palmNumberController: _palmNumberController,
                    typeController: _typeController,
                    rowNumberController: _rowNumberController,
                    columnNumberController: _columnNumberController,
                    sourceController: _sourceController,
                    selectedFarmIdNotifier: _selectedFarmIdNotifier,
                    healthStatusNotifier: _healthStatusNotifier,
                    productionStatusNotifier: _productionStatusNotifier,
                    plantingDateNotifier: _plantingDateNotifier,
                    lastFertilizationDateNotifier: _lastFertilizationDateNotifier,
                    lastIrrigationDateNotifier: _lastIrrigationDateNotifier,
                    lastHarvestDateNotifier: _lastHarvestDateNotifier,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _submitForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditing ? "حفظ التعديلات" : "حفظ النخلة",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}