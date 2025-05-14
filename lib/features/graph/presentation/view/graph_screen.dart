import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../managers/graph_cubit.dart';

class GraphScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphCubit, List<double>>(
      builder: (context, temperatures) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                temperatures.isEmpty
                    ? const Text(
                      'No data available',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    )
                    : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget:
                                  (value, meta) => Text(
                                    value.toStringAsFixed(1),
                                    style: TextStyle(color: Colors.black),
                                  ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget:
                                  (value, meta) => Text(
                                    value.toInt().toString(),
                                    style: TextStyle(color: Colors.black),
                                  ),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots:
                                temperatures
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => FlSpot(e.key.toDouble(), e.value),
                                    )
                                    .toList(),
                            isCurved: true,
                            barWidth: 2,
                            color: Colors.blueAccent,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
          ),
        );
      },
    );
  }
}
