import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_app/constant/constant.dart';
import 'package:health_app/models/step_data.dart';
import 'package:health_app/utils/utils.dart';
import 'package:health_app/view_models/step_counter_view_model.dart';

class StepCounterMonthlyTab extends StatelessWidget {
  final StepCounterViewModel viewModel;

  const StepCounterMonthlyTab({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // Tính toán maxY từ dữ liệu có sẵn
    double maxY = viewModel.monthlyStepsData
        .map((e) => roundToNearestTen(e.steps))
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    // Tạo map để lưu trữ dữ liệu theo ngày
    Map<int, StepData> stepsPerDay = {};

    for (var data in viewModel.monthlyStepsData) {
      stepsPerDay[data.date.day] = data;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            // them thang - nam
            'Monthly steps: ${viewModel.monthlyStepsData.first.date.month}/${viewModel.monthlyStepsData.first.date.year}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1000, // Chiều rộng để có thể scroll
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
                          StepData? data = stepsPerDay[group.x + 1];
                          if (data == null) return null;
                          return BarTooltipItem(
                            'Day: ${data.date.day}\n'
                            'Steps: ${data.steps}\n'
                            'Distance: ${data.distance.toStringAsFixed(2)} m\n'
                            'Calories: ${data.calories.toStringAsFixed(2)} cal\n'
                            'Duration: ${formatDuration(data.duration)}',
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
                              '${value.toInt() + 1}',
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
                              padding: const EdgeInsets.only(
                                  right: 8, top: 10), // Thêm padding bên phải
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
                      31, // Tạo đủ 31 ngày
                      (index) {
                        bool hasData = stepsPerDay.containsKey(index + 1);
                        // Chỉ tạo cột nếu có dữ liệu cho ngày đó
                        return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: (stepsPerDay[index + 1]?.steps ?? 0)
                                    .toDouble(),
                                color: cyanColor,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                            barsSpace: 20 // Thêm khoảng cách giữa các cột
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
