import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_app/models/step_data.dart';

class StepCounterWeekly extends StatelessWidget {
  final List<StepData> weeklyStepData;
  final double goalSteps;
  final List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  StepCounterWeekly({
    required this.weeklyStepData,
    this.goalSteps = 7000, // Mục tiêu mặc định là 7000 bước
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10000,
          minY: 0,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 2000,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      weekDays[value.toInt()],
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2000,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: goalSteps,
                color: Colors.green,
                strokeWidth: 1,
                dashArray: [5, 5], // Tạo đường đứt khúc
              ),
            ],
          ),
          barGroups: List.generate(
            weeklyStepData.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: weeklyStepData[index].steps.toDouble(),
                  color: Color(0xFF4CD9B6),
                  width: 40,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Example usage in your screen:
// class StepCounterScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Sample data - replace with actual data from your database
//     final weeklyStepData = [6000, 9000, 7000, 8000, 5000, 2500, 4000];

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.all(16),
//               child: Text(
//                 'Weekly Steps',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             StepCounterWeekly(
//               weeklyStepData: weeklyStepData,
//               goalSteps: 7000,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
