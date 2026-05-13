import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum SkillChipType { present, missing, neutral }

class SkillChip extends StatelessWidget {
  final String label;
  final SkillChipType type;

  const SkillChip({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case SkillChipType.present:
        borderColor = Colors.green;
        backgroundColor = Colors.green[50]!;
        icon = Icons.check;
        break;
      case SkillChipType.missing:
        borderColor = Colors.amber;
        backgroundColor = Colors.amber[50]!;
        icon = Icons.warning;
        break;
      case SkillChipType.neutral:
        borderColor = Colors.grey;
        backgroundColor = Colors.grey[50]!;
        icon = Icons.circle;
        break;
    }

    return Chip(
      avatar: Icon(icon, color: borderColor, size: 18),
      label: Text(label),
      backgroundColor: backgroundColor,
      side: BorderSide(color: borderColor),
    ).animate().fadeIn().scale();
  }
}