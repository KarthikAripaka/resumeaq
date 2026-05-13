import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    if (8.0 > 8.0) _confettiController.play(); // Placeholder condition
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interview Results')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Overall Score: 8.5', style: TextStyle(fontSize: 24)),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 7.0)]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8.5)]),
                      ],
                    ),
                  ),
                ),
                const Text('Strengths: ...'),
                const Text('Areas to improve: ...'),
                ElevatedButton(onPressed: () {}, child: const Text('Try Again')),
                OutlinedButton(onPressed: () {}, child: const Text('Save & View Analytics')),
              ],
            ),
          ).animate().fadeIn().slideY(),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
          ),
        ],
      ),
    );
  }
}