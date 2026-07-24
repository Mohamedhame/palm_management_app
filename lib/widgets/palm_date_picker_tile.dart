import 'package:flutter/material.dart';

class PalmDatePickerTile extends StatelessWidget {
  final String title;
  final ValueNotifier<DateTime?> notifier;

  const PalmDatePickerTile({
    super.key,
    required this.title,
    required this.notifier,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return "اختر التاريخ";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _selectDate(
    BuildContext context,
    ValueNotifier<DateTime?> notifier,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: notifier.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2E7D32)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      notifier.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: notifier,
      builder: (context, date, child) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: ListTile(
            title: Text(title, style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              _formatDate(date),
              style: TextStyle(
                color: date != null ? const Color(0xFF2E7D32) : Colors.grey,
                fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF2E7D32),
            ),
            onTap: () => _selectDate(context, notifier),
          ),
        );
      },
    );
  }
}