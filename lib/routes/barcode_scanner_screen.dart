import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:nakeel_demo/controller/palms_controller.dart';
import 'package:nakeel_demo/routes/palm_details_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  static const routeName = "/barcode_scanner";

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false; // لمنع تكرار المسح أثناء معالجة الباركود

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? scannedCode = barcodes.first.rawValue;
    if (scannedCode == null || scannedCode.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    final palmsController = context.read<PalmsController>();

    // 🌴 جلب جميع النخيل الخاصة بالمزارع المتاحة للموظف/المستخدم
    final List<Map<String, dynamic>> allUserPalms = palmsController.palms;

    Map<String, dynamic>? matchedPalm;

    // 🔍 مطابقة الباركود الممسوح مع نخيل مزارع الموظف
    for (var palm in allUserPalms) {
      final String farmIdStr = palm['farm_id']?.toString() ?? '0';
      final int palmNumber = palm['palm_number'] ?? 0;
      final String rowStr = palm['row_number']?.toString() ?? '0';
      final String colStr = palm['column_number']?.toString() ?? '0';

      final String expectedBarcode =
          "farm-$farmIdStr-palm-$palmNumber-row-$rowStr-col-$colStr";

      if (scannedCode.trim() == expectedBarcode) {
        matchedPalm = palm;
        break;
      }
    }

    if (!mounted) return;

    if (matchedPalm != null) {
      // ✅ حالة التطابق: الانتقال لصفحة التفاصيل
      final palmToNavigate = matchedPalm;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PalmDetailsScreen(palm: palmToNavigate),
        ),
      );
    } else {
      // ❌ حالة عدم التطابق أو باركود غير تابع لمزارع الموظف
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "الباركود غير صالح أو لا ينتمي للمزارع المصرح لك بها ❌",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      // مهلة زمنية صغيرة قبل التمكين من المسح مجدداً
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "مسح الباركود",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController,
              builder: (context, MobileScannerState state, child) {
                final bool isOn = state.torchState == TorchState.on;
                return Icon(
                  isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: isOn ? Colors.amber : Colors.white,
                );
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _scannerController, onDetect: _onDetect),

          // 🔲 إطار توجيه الكاميرا
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing ? Colors.amber : const Color(0xFF2E7D32),
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // ℹ️ نص توجيهي في الأسفل
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isProcessing
                    ? "جاري التحقق من الباركود..."
                    : "قم بوضع الباركود داخل الإطار للمسح",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
