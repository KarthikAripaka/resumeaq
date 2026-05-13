import 'package:flutter/material.dart';

class LoadingStepsWidget extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const LoadingStepsWidget({super.key, required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;
        return ListTile(
          leading: isCompleted
              ? const Icon(Icons.check_circle, color: Colors.green)
              : isCurrent
                  ? const CircularProgressIndicator()
                  : Icon(Icons.circle, color: Colors.grey),
          title: Text(steps[index]),
        );
      }),
    );
  }
}