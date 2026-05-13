import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);
    final history = ref.watch(sessionHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            stats.when(
              data: (data) => Column(
                children: [
                  Text('Avg ATS: ${data['avgAtsScore']}'),
                  Text('Total Sessions: ${data['totalSessions']}'),
                  Text('Best Score: ${data['bestScore']}'),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [const FlSpot(0, 70), const FlSpot(1, 80)],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      dataEntries: [const RadarEntry(value: 7), const RadarEntry(value: 8)],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: history.when(
                data: (sessions) => ListView(
                  children: sessions.map((s) => Card(child: Text(s.jobRole))).toList(),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(),
    );
  }
}