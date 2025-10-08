import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/workout_history_model.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';
import '../history/history_detail_screen.dart';

class LaporanScreen extends ConsumerWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyFuture = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan & Riwayat'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(workoutHistoryProvider),
        child: historyFuture.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const Center(child: Text("Gagal memuat riwayat.")),
          data: (historyList) {
            if (historyList.isEmpty) {
              return const Center(
                child: Text(
                  "Anda belum menyelesaikan latihan apapun.\nSelesaikan satu sesi untuk melihatnya di sini.",
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Aktivitas Minggu Ini",
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                SizedBox(
                  height: 200,
                  child: WeeklyActivityChart(history: historyList),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Riwayat Lengkap",
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final history = historyList[index];
                    final formattedDate = DateFormat('EEEE, d MMMM y', 'id_ID')
                        .format(history.completedDate);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle_outline,
                            color: Colors.green),
                        title: Text(history.workoutName),
                        subtitle: Text(history.planName),
                        trailing: Text(
                          'Hari ke-${history.dayCompleted}\n$formattedDate',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HistoryDetailScreen(history: history),
                              ));
                        },
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class WeeklyActivityChart extends StatelessWidget {
  final List<WorkoutHistory> history;
  const WeeklyActivityChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final List<int> weeklyData = List.filled(7, 0);
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    for (var item in history) {
      if (item.completedDate
          .isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
        weeklyData[item.completedDate.weekday - 1]++;
      }
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (weeklyData.reduce((a, b) => a > b ? a : b) * 1.5)
                .toDouble()
                .clamp(1, 10),
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const style = TextStyle(fontSize: 10);
                    String text;
                    switch (value.toInt()) {
                      case 0:
                        text = 'SEN';
                        break;
                      case 1:
                        text = 'SEL';
                        break;
                      case 2:
                        text = 'RAB';
                        break;
                      case 3:
                        text = 'KAM';
                        break;
                      case 4:
                        text = 'JUM';
                        break;
                      case 5:
                        text = 'SAB';
                        break;
                      case 6:
                        text = 'MIN';
                        break;
                      default:
                        text = '';
                        break;
                    }
                    return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(text, style: style));
                  },
                  reservedSize: 28,
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            barGroups: List.generate(7, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: weeklyData[index].toDouble(),
                    color: primaryColor,
                    width: 15,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}