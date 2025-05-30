import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SensorChart extends StatelessWidget {
  final String sensorName;
  final List<double> values;

  const SensorChart({
    super.key,
    required this.sensorName,
    required this.values,
  });

  // Mendapatkan warna berdasarkan jenis sensor
  Color _getSensorColor() {
    switch (sensorName) {
      case "pH Tanah":
        return Colors.purple;
      case "Kelembapan Tanah":
        return Colors.blue;
      case "Suhu Tanah":
        return Colors.red;
      case "Curah Hujan":
        return Colors.cyan;
      case "Level Air":
        return Colors.green;
      case "Kecepatan Angin":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Format jam untuk label bawah (misalnya: "14:30")
  String _getTimeLabel(int index, int totalPoints) {
    // Asumsi data dari kanan ke kiri (terbaru di kanan)
    final now = DateTime.now();
    final timePoint = now.subtract(Duration(hours: totalPoints - 1 - index));
    return "${timePoint.hour.toString().padLeft(2, '0')}:${timePoint.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final minY = values.isEmpty ? 0.0 : values.reduce((a, b) => a < b ? a : b);
    final maxY = values.isEmpty ? 10.0 : values.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;
    final sensorColor = _getSensorColor();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sensorName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: sensorColor,
                  ),
                ),
                if (values.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sensorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Terkini: ${values.last.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: sensorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: minY - padding,
                  maxY: maxY + padding,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          if (value % 4 != 0) return const Text('');
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _getTimeLabel(value.toInt(), values.length),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: values.asMap().entries.map(
                        (e) => FlSpot(e.key.toDouble(), e.value),
                      ).toList(),
                      isCurved: true,
                      color: sensorColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: sensorColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: sensorColor.withOpacity(0.1),
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
}
