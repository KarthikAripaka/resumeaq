import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryRadarChart extends StatelessWidget {
  final Map<String, double> categoryScores;

  const CategoryRadarChart({super.key, required this.categoryScores});

  @override
  Widget build(BuildContext context) {
    final data = [
      categoryScores['hr'] ?? 0,
      categoryScores['technical'] ?? 0,
      categoryScores['dsa'] ?? 0,
      categoryScores['project'] ?? 0,
    ];

    return RadarChart(
      RadarChartData(
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: const BorderSide(color: Colors.grey),
        tickBorderData: const BorderSide(color: Colors.grey),
        gridBorderData: const BorderSide(color: Colors.grey, width: 2),
        ticksTextStyle: const TextStyle(color: Colors.transparent),
        tickCount: 5,
        ticksTextStyle: const TextStyle(color: Colors.transparent),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 12),
        getTitle: (index, angle) {
          switch (index) {
            case 0:
              return RadarChartTitle(text: 'HR', angle: angle);
            case 1:
              return RadarChartTitle(text: 'Technical', angle: angle);
            case 2:
              return RadarChartTitle(text: 'DSA', angle: angle);
            case 3:
              return RadarChartTitle(text: 'Project', angle: angle);
            default:
              return const RadarChartTitle(text: '');
          }
        },
        radarShape: RadarShape.polygon,
        dataSets: [
          RadarDataSet(
            fillColor: Colors.blue.withOpacity(0.2),
            borderColor: Colors.blue,
            entryRadius: 3,
            dataEntries: data.map((score) => RadarEntry(value: score)).toList(),
            borderWidth: 2,
          ),
        ],
      ),
    );
  }
}