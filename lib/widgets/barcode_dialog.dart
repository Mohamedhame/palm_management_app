import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BarcodeDialog extends StatelessWidget {
  final String barcodeData;
  final int palmNumber;

  // 🔑 مفتاح لالتقاط صورة للـ Widget
  final GlobalKey _globalKey = GlobalKey();

  BarcodeDialog({
    super.key,
    required this.barcodeData,
    required this.palmNumber,
  });

  static Future<void> show(
    BuildContext context, {
    required String barcodeData,
    required int palmNumber,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) =>
              BarcodeDialog(barcodeData: barcodeData, palmNumber: palmNumber),
    );
  }

  // 📸 دالة التقاط الصورة من RepaintBoundary وتحويلها إلى Uint8List
  Future<Uint8List?> _capturePngBytes() async {
    try {
      RenderRepaintBoundary? boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error capturing barcode image: $e");
      return null;
    }
  }

  // 💾 دالة الحفظ في المعرض
  Future<bool> _saveBarcodeToGallery(BuildContext context) async {
    try {
      final bytes = await _capturePngBytes();
      if (bytes != null) {
        await Gal.putImageBytes(bytes, name: "barcode_palm_$palmNumber");

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم حفظ صورة الباركود في المعرض بنجاح 🖼️"),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
          return true;
        }
      }
    } on GalException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("خطأ أثناء الحفظ: ${e.type.message}"),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ غير متوقع: $e"),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
    return false;
  }

  // 📲 دالة مشاركة صورة الباركود
  Future<void> _shareBarcodeImage(BuildContext context) async {
    try {
      final bytes = await _capturePngBytes();
      if (bytes == null) return;

      // 1. حفظ الصورة مؤقتاً في ذاكرة الجهاز
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/barcode_palm_$palmNumber.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // 2. فتح نافذة المشاركة
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'باركود نخلة رقم: #$palmNumber\nالرمز: $barcodeData',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ أثناء المشاركة: $e"),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  Future<void> _printBarcodePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  "نخلة رقم: #$palmNumber",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: barcodeData,
                  width: 180,
                  height: 70,
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'barcode_palm_$palmNumber.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Center(
        child: Text(
          "باركود النخلة (#$palmNumber)",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            key: _globalKey,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: barcodeData,
                    width: 230,
                    height: 90,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "نخلة رقم: #$palmNumber",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(
            barcodeData,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // 1️⃣ زر الطباعة
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0288D1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _printBarcodePdf,
                    icon: const Icon(
                      Icons.print_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      "طباعة",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 2️⃣ زر المشاركة
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _shareBarcodeImage(context),
                    icon: const Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      "مشاركة",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 3️⃣ زر حفظ وإغلاق
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  await _saveBarcodeToGallery(context);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(
                  Icons.save_alt_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  "حفظ في المعرض",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}