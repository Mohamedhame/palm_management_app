import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nakeel_demo/controller/palms_controller.dart';
import 'package:nakeel_demo/routes/add_palm_screen.dart';
import 'package:nakeel_demo/routes/palm_details_screen.dart'; // 💡 استيراد شاشة التفاصيل
import 'package:nakeel_demo/widgets/barcode_dialog.dart';

class PalmsListScreen extends StatefulWidget {
  const PalmsListScreen({super.key});

  static const routeName = "/palms_list";

  @override
  State<PalmsListScreen> createState() => _PalmsListScreenState();
}

class _PalmsListScreenState extends State<PalmsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PalmsController>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getHealthColor(String status) {
    switch (status) {
      case 'infected':
        return Colors.red;
      case 'warning':
        return Colors.amber.shade700;
      case 'healthy':
      default:
        return const Color(0xFF2E7D32);
    }
  }

  String _getHealthText(String status) {
    switch (status) {
      case 'infected':
        return "مصابة 🔴";
      case 'warning':
        return "تحت الملاحظة 🟡";
      case 'healthy':
      default:
        return "سليمة 🟢";
    }
  }

  void _showBarcodeDialog(BuildContext context, Map<String, dynamic> palm) {
    final String farmIdStr = palm['farm_id']?.toString() ?? '0';
    final int palmNumber = palm['palm_number'] ?? 0;
    final String rowStr = palm['row_number']?.toString() ?? '0';
    final String colStr = palm['column_number']?.toString() ?? '0';
    final String barcodeData =
        "farm-$farmIdStr-palm-$palmNumber-row-$rowStr-col-$colStr";
    BarcodeDialog.show(
      context,
      barcodeData: barcodeData,
      palmNumber: palmNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        title: const Text(
          "قائمة النخيل التفصيلية",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<PalmsController>(
        builder: (context, controller, child) {
          final palmsList = controller.filteredPalms;

          return Column(
            children: [
              // 🌿 1. شريط اختيار المزرعة والبحث
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<int?>(
                      value: controller.selectedFarm?['id'] as int?,
                      decoration: InputDecoration(
                        labelText: "تصفية حسب المزرعة",
                        prefixIcon: const Icon(
                          Icons.agriculture_rounded,
                          color: Color(0xFF2E7D32),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text("جميع المزارع 🌴"),
                        ),
                        ...controller.farms.map((farm) {
                          return DropdownMenuItem<int?>(
                            value: farm['id'] as int,
                            child: Text(farm['name'] as String),
                          );
                        }),
                      ],
                      onChanged: (farmId) {
                        if (farmId == null) {
                          controller.selectFarm(null);
                        } else {
                          final selected = controller.farms.firstWhere(
                            (f) => f['id'] == farmId,
                            orElse: () => controller.farms.first,
                          );
                          controller.selectFarm(selected);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => controller.setSearchQuery(val),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "ابحث برقم النخلة أو النوع...",
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF2E7D32),
                        ),
                        suffixIcon:
                            controller.searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    controller.setSearchQuery('');
                                  },
                                )
                                : null,
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(context, controller, "الكل", "all"),
                          _buildFilterChip(
                            context,
                            controller,
                            "سليمة 🟢",
                            "healthy",
                          ),
                          _buildFilterChip(
                            context,
                            controller,
                            "مصابة 🔴",
                            "infected",
                          ),
                          _buildFilterChip(
                            context,
                            controller,
                            "ملاحظة 🟡",
                            "warning",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 📋 2. قائمة الكروت
              Expanded(
                child:
                    controller.isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2E7D32),
                          ),
                        )
                        : palmsList.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                controller.searchQuery.isNotEmpty
                                    ? "لا توجد نخلة برقم أو اسم \"${controller.searchQuery}\""
                                    : "لا توجد نخيل مسجلة لهذا التحديد",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: palmsList.length,
                          itemBuilder: (ctx, index) {
                            final palm = palmsList[index];
                            final status = palm['health_status'] ?? 'healthy';
                            final bool canManage =
                                (controller.isAdmin || controller.canAdd);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              clipBehavior: Clip.antiAlias, // 👈 لضمان تجاوب التظليل مع الحواف الدائرية
                              child: InkWell(
                                onTap: () {
                                  // 🚀 الانتقال إلى صفحة تفاصيل النخلة
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PalmDetailsScreen(palm: palm),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: _getHealthColor(
                                                    status,
                                                  ).withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.nature_rounded,
                                                  color: _getHealthColor(status),
                                                  size: 26,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                "نخلة رقم #${palm['palm_number']}",
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getHealthColor(
                                                status,
                                              ).withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(
                                                20,
                                              ),
                                            ),
                                            child: Text(
                                              _getHealthText(status),
                                              style: TextStyle(
                                                color: _getHealthColor(status),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoTile(
                                            "النوع",
                                            palm['type'] ?? 'غير محدد',
                                          ),
                                          _buildInfoTile(
                                            "الموقع",
                                            "صف ${palm['row_number'] ?? '-'} / عمود ${palm['column_number'] ?? '-'}",
                                          ),
                                          _buildInfoTile(
                                            "الإنتاج",
                                            palm['production_status'] ==
                                                    'producing'
                                                ? "مثمرة 🌴"
                                                : "فسيلة 🌿",
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // 🔘 صف أزرار التحكم
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed:
                                                () => _showBarcodeDialog(
                                                  context,
                                                  palm,
                                                ),
                                            icon: const Icon(
                                              Icons.qr_code_rounded,
                                              size: 18,
                                              color: Color(0xFF0288D1),
                                            ),
                                            label: const Text(
                                              "الباركود",
                                              style: TextStyle(
                                                color: Color(0xFF0288D1),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                          if (canManage) ...[
                                            TextButton.icon(
                                              onPressed: () async {
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) => AddPalmScreen(
                                                          palmData: palm,
                                                          initialFarmId:
                                                              controller
                                                                  .selectedFarm?['id']
                                                                  ?.toString(),
                                                        ),
                                                  ),
                                                );
                                                if (result == true) {
                                                  controller
                                                      .fetchPalmsForSelectedFarm();
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.edit_rounded,
                                                size: 18,
                                                color: Color(0xFF2E7D32),
                                              ),
                                              label: const Text(
                                                "تعديل",
                                                style: TextStyle(
                                                  color: Color(0xFF2E7D32),
                                                ),
                                              ),
                                            ),

                                            TextButton.icon(
                                              onPressed:
                                                  () => _confirmDelete(
                                                    context,
                                                    controller,
                                                    palm,
                                                  ),
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                                color: Colors.red,
                                              ),
                                              label: const Text(
                                                "حذف",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    PalmsController controller,
    String label,
    String value,
  ) {
    final isSelected = controller.selectedStatusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
        checkmarkColor: const Color(0xFF2E7D32),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) => controller.setStatusFilter(value),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    PalmsController controller,
    Map<String, dynamic> palm,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogCtx) => AlertDialog(
            title: const Text("تأكيد الحذف"),
            content: Text(
              "هل أنت تأكد من حذف النخلة رقم #${palm['palm_number']}؟",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text("إلغاء"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pop(dialogCtx);
                  final palmId = palm['id'] as int?;
                  if (palmId != null) {
                    await controller.deletePalm(palmId);
                  }
                },
                child: const Text("حذف"),
              ),
            ],
          ),
    );
  }
}