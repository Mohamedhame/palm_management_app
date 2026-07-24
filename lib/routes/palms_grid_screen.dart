import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nakeel_demo/controller/palms_controller.dart';
import 'package:nakeel_demo/routes/add_palm_screen.dart';
import 'package:nakeel_demo/widgets/barcode_dialog.dart';

class PalmsGridScreen extends StatefulWidget {
  const PalmsGridScreen({super.key});

  static const routeName = "/palms_grid";

  @override
  State<PalmsGridScreen> createState() => _PalmsGridScreenState();
}

class _PalmsGridScreenState extends State<PalmsGridScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PalmsController>().init();
    });
  }

  Color _getHealthColor(String status) {
    switch (status) {
      case 'infected':
        return Colors.red;
      case 'warning':
        return Colors.amber.shade700;
      case 'healthy':
        return const Color(0xFF2E7D32);
      case 'empty':
      default:
        return Colors.grey.shade400; // 👈 لون رمادي للمكان الفارغ
    }
  }

  // 🏷️ دالة إظهار مربع حوار الباركود
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

  void _showPalmDetailsBottomSheet(
    BuildContext context,
    Map<String, dynamic> palm,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.nature_rounded,
                        color: _getHealthColor(
                          palm['health_status'] ?? 'healthy',
                        ),
                        size: 32,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "نخلة رقم #${palm['palm_number']}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Chip(
                    label: Text(
                      palm['health_status'] == 'healthy'
                          ? "سليمة"
                          : palm['health_status'] == 'infected'
                          ? "مصابة"
                          : "تحت الملاحظة",
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getHealthColor(
                      palm['health_status'] ?? 'healthy',
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailTile("الصف", "${palm['row_number'] ?? '-'}"),
                  _buildDetailTile("العمود", "${palm['column_number'] ?? '-'}"),
                  _buildDetailTile("النوع", "${palm['type'] ?? '-'}"),
                  _buildDetailTile(
                    "مرحلة النمو",
                    palm['production_status'] == 'producing'
                        ? "مثمرة"
                        : "فسيلة",
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 🔘 أزرار التحكم (الباركود، تعديل، حذف)
              Consumer<PalmsController>(
                builder: (context, controller, child) {
                  final bool canManage =
                      (controller.isAdmin || controller.canAdd);

                  return Row(
                    children: [
                      // 🏷️ 1. زر الباركود
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showBarcodeDialog(context, palm);
                          },
                          icon: const Icon(Icons.qr_code_rounded, size: 20),
                          label: const Text("الباركود"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0288D1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      if (canManage) ...[
                        const SizedBox(width: 8),

                        // ✏️ 2. زر التعديل
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              final palmsController =
                                  context.read<PalmsController>();

                              Navigator.pop(ctx);

                              final result = await navigator.push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => AddPalmScreen(
                                        palmData: palm,
                                        initialFarmId:
                                            controller.selectedFarm?['id']
                                                ?.toString(),
                                      ),
                                ),
                              );

                              if (result == true) {
                                await palmsController
                                    .fetchPalmsForSelectedFarm();
                              }
                            },
                            icon: const Icon(Icons.edit_rounded, size: 20),
                            label: const Text("تعديل"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 🗑️ 3. زر الحذف
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (dialogCtx) => AlertDialog(
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
                                          onPressed:
                                              () => Navigator.pop(dialogCtx),
                                          child: const Text(
                                            "إلغاء",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(dialogCtx);
                                            Navigator.pop(ctx);

                                            final palmId = palm['id'] as int?;
                                            if (palmId != null) {
                                              final success = await controller
                                                  .deletePalm(palmId);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      success
                                                          ? "تم حذف النخلة بنجاح 🗑️"
                                                          : "حدث خطأ أثناء الحذف ❌",
                                                    ),
                                                    backgroundColor:
                                                        success
                                                            ? Colors.green
                                                            : Colors.red,
                                                  ),
                                                );
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
                              size: 20,
                            ),
                            label: const Text("حذف"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildDetailTile(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PalmsController>(
      builder: (context, controller, child) {
        final selectedFarmId = controller.selectedFarm?['id'] as int?;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F4),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2E7D32),
            elevation: 2,
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            title:
                controller.userFarms.isEmpty
                    ? const Text(
                      "لا توجد مزارع",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                    : DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedFarmId,
                        dropdownColor: const Color(0xFF2E7D32),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        onChanged: (farmId) {
                          if (farmId != null) {
                            final selected = controller.userFarms.firstWhere(
                              (f) => f['id'] == farmId,
                              orElse: () => controller.userFarms.first,
                            );
                            controller.selectFarm(selected);
                          }
                        },
                        items:
                            controller.userFarms.map((farm) {
                              return DropdownMenuItem<int>(
                                value: farm['id'] as int,
                                child: Text(
                                  farm['name'] as String,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
          ),
          body:
              controller.isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  )
                  : controller.userFarms.isEmpty
                  ? const Center(child: Text("يرجى إضافة مزرعة أولاً"))
                  : Column(
                    children: [
                      // شريط الإحصائيات للمزرعة المحددة
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatBadge(
                              "إجمالي النخيل",
                              "${controller.totalPalms}",
                              Colors.blueGrey,
                            ),
                            _buildStatBadge(
                              "سليم",
                              "${controller.healthyCount}",
                              const Color(0xFF2E7D32),
                            ),
                            _buildStatBadge(
                              "مصاب",
                              "${controller.infectedCount}",
                              Colors.red,
                            ),
                            _buildStatBadge(
                              "ملاحظة",
                              "${controller.warningCount}",
                              Colors.amber.shade700,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // شبكة الرسم التفاعلية
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              color: const Color(0xFFEFEBE9),
                              child: InteractiveViewer(
                                constrained: false,
                                boundaryMargin: const EdgeInsets.all(100),
                                minScale: 0.5,
                                maxScale: 3.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(controller.maxRows, (
                                      rowIndex,
                                    ) {
                                      final currentRow = rowIndex + 1;
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(controller.maxColumns, (
                                          colIndex,
                                        ) {
                                          final currentCol = colIndex + 1;

                                          final palm = controller.palms
                                              .firstWhere(
                                                (p) =>
                                                    p['row_number'] ==
                                                        currentRow &&
                                                    p['column_number'] ==
                                                        currentCol,
                                                orElse: () => {},
                                              );

                                          final bool hasPalm = palm.isNotEmpty;
                                          final String status =
                                              hasPalm
                                                  ? (palm['health_status'] ??
                                                      'healthy')
                                                  : 'empty';

                                          return GestureDetector(
                                            onTap: () {
                                              if (hasPalm) {
                                                _showPalmDetailsBottomSheet(
                                                  context,
                                                  palm,
                                                );
                                              } else if (controller.isAdmin ||
                                                  controller.canAdd) {
                                                // ➕ إتاحة إضافة نخلة فوراً عند الضغط على المربع الفارغ
                                                Navigator.pushNamed(
                                                  context,
                                                  AddPalmScreen.routeName,
                                                  arguments: {
                                                    'farm_id':
                                                        controller
                                                            .selectedFarm?['id']
                                                            ?.toString(),
                                                    'row_number': currentRow,
                                                    'column_number': currentCol,
                                                  },
                                                );
                                              }
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.all(10),
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color:
                                                    hasPalm
                                                        ? Colors.white
                                                        : Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: _getHealthColor(
                                                    status,
                                                  ).withOpacity(
                                                    hasPalm ? 0.6 : 0.3,
                                                  ),
                                                  width: hasPalm ? 2 : 1.5,
                                                ),
                                                boxShadow:
                                                    hasPalm
                                                        ? [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.05,
                                                                ),
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  2,
                                                                ),
                                                          ),
                                                        ]
                                                        : [],
                                              ),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // 🌴 أيقونة النخلة أو ➕ أيقونة مكان فارغ
                                                  Icon(
                                                    hasPalm
                                                        ? Icons.nature_rounded
                                                        : Icons
                                                            .add_location_alt_outlined,
                                                    size: hasPalm ? 32 : 24,
                                                    color: _getHealthColor(
                                                      status,
                                                    ),
                                                  ),

                                                  // 🏷️ رقم النخلة إن وجدت، أو كلمة "فارغ"
                                                  Positioned(
                                                    bottom: 3,
                                                    child: Text(
                                                      hasPalm
                                                          ? "#${palm['palm_number']}"
                                                          : "فارغ",
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            hasPalm
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                        color:
                                                            hasPalm
                                                                ? Colors.black87
                                                                : Colors
                                                                    .grey
                                                                    .shade500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          floatingActionButton:
              (controller.isAdmin || controller.canAdd)
                  ? FloatingActionButton.extended(
                    onPressed: () async {
                      final bool? shouldRefresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddPalmScreen(
                                initialFarmId:
                                    controller.selectedFarm?['id']?.toString(),
                              ),
                        ),
                      );
                      if (shouldRefresh == true) {
                        await controller.fetchPalmsForSelectedFarm();
                      }
                    },
                    backgroundColor: const Color(0xFF2E7D32),
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text(
                      "إضافة نخلة",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildStatBadge(String title, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
      ],
    );
  }
}
