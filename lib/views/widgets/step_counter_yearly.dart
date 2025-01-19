import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_app/constant/constant.dart';
import 'package:health_app/utils/utils.dart';
import 'package:health_app/view_models/step_counter_view_model.dart';

class StepCounterYearlyTab extends StatelessWidget {
  final StepCounterViewModel viewModel;

  const StepCounterYearlyTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    double maxY = viewModel.yearlyStepsData.values
        .map(
          (e) => roundToNearestTen(e),
        )
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Yearly steps: ${DateTime.now().year}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 480,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.start,
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 12,
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipColor: (group) => Color(0xFF00c853),
                        maxContentWidth: 200,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          int month = group.x + 1;
                          int? steps = viewModel.yearlyStepsData[month];
                          if (steps == null) return null;
                          return BarTooltipItem(
                            'Month: ${getMonthName(group.x)}\n'
                            'Steps: $steps',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
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
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8, top: 10),
                              child: Text(
                                '${value.toInt()}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      12,
                      (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: (viewModel.yearlyStepsData[index + 1] ?? 0)
                                  .toDouble(),
                              color: cyanColor,
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      },
                    ),
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
