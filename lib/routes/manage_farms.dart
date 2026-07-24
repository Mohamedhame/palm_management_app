import 'package:flutter/material.dart';
import 'package:nakeel_demo/controller/farms_controller.dart';
import 'package:nakeel_demo/routes/farm_details_screen.dart';
import 'package:nakeel_demo/widgets/build_stat_item.dart';
import 'package:provider/provider.dart';

class ManageFarms extends StatefulWidget {
  const ManageFarms({super.key});

  static const routeName = "/manage_farms";

  @override
  State<ManageFarms> createState() => _ManageFarmsState();
}

class _ManageFarmsState extends State<ManageFarms> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmsController>().loadFarms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<FarmsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        title: const Text(
          "إدارة المزارع المسجلة",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<FarmsController>(
        builder: (context, farmsController, child) {
          if (farmsController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            );
          }

          if (farmsController.farms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gite_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "لا توجد مزارع مسجلة حالياً",
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

          final farmsList = farmsController.farms;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: farmsList.length,
            itemBuilder: (context, index) {
              final farm = farmsList[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  // onTapDown: (details) => tapDetails = details,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FarmDetailsScreen(farmId: farm['id']),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.gite_rounded,
                                  color: Color(0xFF8D6E63),
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  farm['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Chip(
                              label: Text(
                                "#${index + 1}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: const Color(0xFF8D6E63),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24, thickness: 1),

                        if (farm['location'] != null &&
                            (farm['location'] as String).isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                farm['location'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BuildStatItem(
                              icon: Icons.square_foot_rounded,
                              label: "المساحة",
                              value: "${farm['area_in_acres'] ?? 0} متر مربع",
                            ),
                            BuildStatItem(
                              icon: Icons.nature_rounded,
                              label: "النخيل",
                              value: "${farm['total_palms'] ?? 0} نخلة",
                            ),
                            BuildStatItem(
                              icon: Icons.people_alt_rounded,
                              label: "العمال",
                              value: "${farm['total_employees'] ?? 0} موظف",
                            ),
                          ],
                        ),

                        if (farm['notes'] != null &&
                            (farm['notes'] as String).isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "ملاحظات: ${farm['notes']}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
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
        backgroundColor: const Color(0xFF8D6E63),
        icon: const Icon(Icons.gite_rounded, color: Colors.white),
        label: const Text(
          "إضافة مزرعة",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
