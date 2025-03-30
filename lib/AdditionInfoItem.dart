import 'package:flutter/material.dart';

class AdditionInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AdditionInfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8.0),
        Text(label),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
