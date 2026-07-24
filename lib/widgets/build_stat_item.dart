import 'package:flutter/material.dart';

class BuildStatItem extends StatelessWidget {
  const BuildStatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
