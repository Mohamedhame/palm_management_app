import 'package:flutter/material.dart';
import 'package:nakeel_demo/controller/farm_details_controller.dart';
import 'package:nakeel_demo/controller/farms_controller.dart';
import 'package:nakeel_demo/routes/add_farm_screen.dart';
import 'package:nakeel_demo/services/database_helper.dart';
import 'package:provider/provider.dart';

class FarmDetailsScreen extends StatefulWidget {
  final int farmId;

  const FarmDetailsScreen({super.key, required this.farmId});

  static const routeName = "/farm_details";

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  late FarmDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FarmDetailsController(farmId: widget.farmId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadFarmDetails();
    });
  }

  // دالة تأكيد وتنفيذ الحذف
  void _confirmDeleteFarm(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("حذف المزرعة"),
            content: const Text(
              "هل أنت تأكد من رغبتك في حذف هذه المزرعة؟ سيؤدي ذلك إلى حذف كافة بيانات النخيل المرتبطة بها تلقائياً.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "إلغاء",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await DatabaseHelper.instance.deleteFarm(widget.farmId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم حذف المزرعة بنجاح"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context, true);
                      await context.read<FarmsController>().loadFarms();
                      await _controller.loadFarmDetails();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("حدث خطأ أثناء الحذف: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text("حذف", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  // دالة الانتقال لشاشة التعديل
  void _navigateToEditFarm(Map<String, dynamic> farm) async {
    final bool? shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFarmScreen(farmToEdit: farm)),
    );
    if (shouldRefresh == true) {
      await context.read<FarmsController>().loadFarms();
      await _controller.loadFarmDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FarmDetailsController>.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F4),
        appBar: AppBar(
          title: const Text(
            "بيانات المزرعة التفصيلية",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF2E7D32),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<FarmDetailsController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              );
            }

            final farm = controller.farm;
            if (farm == null) {
              return const Center(
                child: Text("لم يتم العثور على بيانات المزرعة"),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFarmHeaderCard(farm),
                  const SizedBox(height: 20),

                  // 2. كارت ملخص إحصائيات الصحة والنمو
                  _buildSectionTitle(
                    "حالة النخيل والنمو",
                    Icons.health_and_safety_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildHealthAndGrowthGrid(controller),
                  const SizedBox(height: 20),

                  // 3. كارت توزيع الأنواع
                  _buildSectionTitle(
                    "أنواع النخيل والمجموع",
                    Icons.eco_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildPalmTypesCard(controller),
                  const SizedBox(height: 20),

                  // 4. كارت العاملين بالمزرعة
                  _buildSectionTitle(
                    "العاملين بالمزرعة",
                    Icons.people_alt_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildEmployeesCard(controller),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 1. كارت العنوان مع زرين للتعديل والحذف
  Widget _buildFarmHeaderCard(Map<String, dynamic> farm) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.gite_rounded,
                    color: Color(0xFF2E7D32),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farm['name'] ?? 'بدون اسم',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              (farm['location'] != null &&
                                      farm['location'].toString().isNotEmpty)
                                  ? farm['location']
                                  : 'الموقع غير محدد',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🌟 شريط أزرار التعديل والحذف 🌟
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0288D1),
                      side: const BorderSide(color: Color(0xFF0288D1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => _navigateToEditFarm(farm),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text(
                      "تعديل",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => _confirmDeleteFarm(context),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text(
                      "حذف",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderSubItem(
                  "المساحة",
                  "${farm['area_in_acres'] ?? 0} متر مربع",
                  Icons.square_foot_rounded,
                ),
                _buildHeaderSubItem(
                  "مسافة الغرس",
                  "${farm['palm_spacing'] ?? '-'} م",
                  Icons.straighten_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSubItem(String title, String val, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildHealthAndGrowthGrid(FarmDetailsController controller) {
    final prod = controller.productionStatusCounts;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatBadge(
                "النخل السليم",
                "${controller.healthyCount}",
                Colors.green,
                Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatBadge(
                "النخل المصاب",
                "${controller.infectedCount}",
                Colors.red,
                Icons.warning_amber_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatBadge(
                "الفسائل",
                "${prod['فسيلة'] ?? 0}",
                Colors.orange,
                Icons.eco_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatBadge(
                "المثمرة",
                "${prod['مثمرة'] ?? 0}",
                Colors.teal,
                Icons.forest_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatBadge(
                "المتوقفة",
                "${prod['متوقفة'] ?? 0}",
                Colors.grey,
                Icons.block_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBadge(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildPalmTypesCard(FarmDetailsController controller) {
    final types = controller.typeCounts;

    if (types.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text("لا يوجد نخيل مسجل في هذه المزرعة بعد")),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "إجمالي النخيل المسجل",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${controller.palms.length} نخلة",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  types.entries.map((entry) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: const Color(0xFF2E7D32),
                        child: Text(
                          "${entry.value}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      label: Text("${entry.key}"),
                      backgroundColor: const Color(0xFFF1F8E9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeesCard(FarmDetailsController controller) {
    final employees = controller.employees;

    if (employees.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "لا يوجد موظفين مخصصين لهذه المزرعة حالياً",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: employees.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final emp = employees[index];
          final bool canAdd = emp['can_add'] == 1;

          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.person, color: Color(0xFF2E7D32)),
            ),
            title: Text(
              emp['email'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              "معرف الموظف: #${emp['id']}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: canAdd ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                canAdd ? "إضافة وتعديل" : "قراءة فقط",
                style: TextStyle(
                  fontSize: 11,
                  color: canAdd ? Colors.green[800] : Colors.orange[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
