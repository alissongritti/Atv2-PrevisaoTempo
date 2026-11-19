import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/previsao_dia.dart';

/// Gráfico interativo de variação de temperaturas (Mínima e Máxima) ao longo dos 4 dias.
class TemperatureChart extends StatelessWidget {
  final List<PrevisaoDia> dias;

  const TemperatureChart({super.key, required this.dias});

  @override
  Widget build(BuildContext context) {
    if (dias.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calcula limites para o eixo Y
    int minTemp = dias.map((d) => d.minima).reduce(min);
    int maxTemp = dias.map((d) => d.maxima).reduce(max);
    double yMin = (minTemp - 2).floorToDouble();
    double yMax = (maxTemp + 2).ceilToDouble();
    if (yMin == yMax) {
      yMin -= 5;
      yMax += 5;
    }

    final spotsMax = <FlSpot>[];
    final spotsMin = <FlSpot>[];

    for (int i = 0; i < dias.length; i++) {
      spotsMax.add(FlSpot(i.toDouble(), dias[i].maxima.toDouble()));
      spotsMin.add(FlSpot(i.toDouble(), dias[i].minima.toDouble()));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart_rounded, color: Colors.indigo, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Variação de Temperatura',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Legenda
            Row(
              children: [
                _buildLegendItem(color: Colors.deepOrangeAccent, label: 'Máxima'),
                const SizedBox(width: 16),
                _buildLegendItem(color: Colors.blueAccent, label: 'Mínima'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (dias.length - 1).toDouble(),
                  minY: yMin,
                  maxY: yMax,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.15),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}°',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= dias.length) {
                            return const SizedBox.shrink();
                          }
                          final data = dias[index].dia;
                          final label = DateFormat('dd/MM').format(data);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Curva de Temperaturas Máximas
                    LineChartBarData(
                      spots: spotsMax,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: Colors.deepOrangeAccent,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.deepOrangeAccent,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepOrangeAccent.withOpacity(0.2),
                            Colors.deepOrangeAccent.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Curva de Temperaturas Mínimas
                    LineChartBarData(
                      spots: spotsMin,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: Colors.blueAccent,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.blueAccent,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(0.2),
                            Colors.blueAccent.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
