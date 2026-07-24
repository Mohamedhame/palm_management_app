import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nakeel_demo/controller/palms_controller.dart';
import 'package:nakeel_demo/routes/add_palm_screen.dart';
import 'package:nakeel_demo/widgets/barcode_dialog.dart';

class PalmDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> palm;

  const PalmDetailsScreen({super.key, required this.palm});

  static const routeName = "/palm_details";

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

  String _getProductionText(String status) {
    switch (status) {
      case 'producing':
        return "مثمرة 🌴";
      case 'stopped':
        return "متوقفة 🛑";
      case 'baby':
      default:
        return "فسيلة 🌿";
    }
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return "غير مسجل";
    try {
      final dt = DateTime.parse(dateStr.toString());
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateStr.toString();
    }
  }

  void _showBarcode(BuildContext context) {
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
    final status = palm['health_status'] ?? 'healthy';
    final int palmNumber = palm['palm_number'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        title: Text(
          "تفاصيل النخلة #$palmNumber",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_rounded, color: Colors.white),
            tooltip: "عرض الباركود",
            onPressed: () => _showBarcode(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🌴 البطاقة الرئيسية العامة
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getHealthColor(status).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.nature_rounded,
                                color: _getHealthColor(status),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "نخلة رقم #$palmNumber",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "النوع: ${palm['type'] ?? 'غير محدد'}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getHealthColor(status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getHealthText(status),
                            style: TextStyle(
                              color: _getHealthColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📍 بطاقة الموقع والحالة الإنتاجية
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "بيانات الموقع والمصدر",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailTile(
                            Icons.table_rows_rounded,
                            "رقم الصف",
                            palm['row_number']?.toString() ?? 'غير محدد',
                          ),
                        ),
                        Expanded(
                          child: _buildDetailTile(
                            Icons.view_column_rounded,
                            "رقم العمود",
                            palm['column_number']?.toString() ?? 'غير محدد',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailTile(
                            Icons.eco_rounded,
                            "حالة الإنتاج",
                            _getProductionText(
                              palm['production_status'] ?? '',
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildDetailTile(
                            Icons.place_rounded,
                            "المصدر / الأصل",
                            palm['source']?.toString().isNotEmpty == true
                                ? palm['source']
                                : 'غير محدد',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📅 بطاقة السجل والتواريخ الزراعية
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "التواريخ والعمليات الزراعية",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const Divider(height: 20),
                    _buildDateRow(
                      Icons.calendar_today_rounded,
                      "تاريخ الغرس",
                      _formatDate(palm['planting_date']),
                    ),
                    const SizedBox(height: 12),
                    _buildDateRow(
                      Icons.water_drop_rounded,
                      "آخر تاريخ ري",
                      _formatDate(palm['last_irrigation_date']),
                    ),
                    const SizedBox(height: 12),
                    _buildDateRow(
                      Icons.science_rounded,
                      "آخر تاريخ تسميد",
                      _formatDate(palm['last_fertilization_date']),
                    ),
                    const SizedBox(height: 12),
                    _buildDateRow(
                      Icons.shopping_basket_rounded,
                      "آخر تاريخ حصاد",
                      _formatDate(palm['last_harvest_date']),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🏷️ زر إظهار الباركود في الأسفل
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0288D1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showBarcode(context),
                icon: const Icon(Icons.qr_code_rounded, color: Colors.white),
                label: const Text(
                  "عرض وطباعة الباركود",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ✏️ 🗑️ أزرار التعديل والحذف (تظهر فقط للأدمن أو لمن يملك صلاحية الإضافة)
            Consumer<PalmsController>(
              builder: (context, controller, child) {
                final bool canManage =
                    controller.isAdmin || controller.canAdd;

                if (!canManage) return const SizedBox.shrink();

                return Row(
                  children: [
                    // ✏️ زر التعديل
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final palmsController =
                                context.read<PalmsController>();

                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddPalmScreen(
                                  palmData: palm,
                                  initialFarmId:
                                      palm['farm_id']?.toString() ??
                                      controller.selectedFarm?['id']
                                          ?.toString(),
                                ),
                              ),
                            );

                            if (result == true) {
                              await palmsController
                                  .fetchPalmsForSelectedFarm();
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          icon: const Icon(Icons.edit_rounded, color: Colors.white),
                          label: const Text(
                            "تعديل",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 🗑️ زر الحذف
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogCtx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text("تأكيد الحذف"),
                                  ],
                                ),
                                content: Text(
                                  "هل أنت تأكد من حذف النخلة رقم #${palm['palm_number']}؟ لن يمكنك استرجاعها بعد الحذف.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogCtx),
                                    child: const Text(
                                      "إلغاء",
                                      style: TextStyle(color: Colors.grey),
                                    ),
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
                                        final success = await controller
                                            .deletePalm(palmId);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                success
                                                    ? "تم حذف النخلة بنجاح 🗑️"
                                                    : "حدث خطأ أثناء الحذف ❌",
                                              ),
                                              backgroundColor: success
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          );
                                          if (success) {
                                            Navigator.pop(context);
                                          }
                                        }
                                      }
                                    },
                                    child: const Text("حذف"),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "حذف",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRow(IconData icon, String title, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
        Text(
          date,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }
}