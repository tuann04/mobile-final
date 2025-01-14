import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StepCounterYearlyTab extends StatelessWidget {
  final Map<int, int> yearlyStepData;
  final String Function(int month) getMonthName;

  const StepCounterYearlyTab({
    Key? key,
    required this.yearlyStepData,
    required this.getMonthName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double maxY =
        yearlyStepData.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Yearly steps',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          getMonthName(value.toInt()),
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  12,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (yearlyStepData[index + 1] ?? 0).toDouble(),
                        color: Theme.of(context).primaryColor,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
