import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/weight_entry.dart';
import '../../services/firestore_service.dart';

class WeightHistoryScreen extends StatefulWidget {
  const WeightHistoryScreen({super.key});

  @override
  State<WeightHistoryScreen> createState() =>
      _WeightHistoryScreenState();
}

class _WeightHistoryScreenState
    extends State<WeightHistoryScreen> {
  final _firestoreService = FirestoreService();

  List<WeightEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final history =
          await _firestoreService.getWeightHistory(
        user.uid,
      );

      final now = DateTime.now();

      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final firstDay = today.subtract(
        const Duration(days: 6),
      );

      final last7Days = history.where((entry) {
        final entryDate = DateTime(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        );

        return !entryDate.isBefore(firstDay) &&
            !entryDate.isAfter(today);
      }).toList();

      last7Days.sort(
        (a, b) => a.date.compareTo(b.date),
      );

      if (!mounted) return;

      setState(() {
        _entries = last7Days;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Weight History Error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load weight history',
          ),
        ),
      );
    }
  }

  WeightEntry? _entryForDay(int dayIndex) {
    final today = DateTime.now();

    final targetDate = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(
      Duration(days: 6 - dayIndex),
    );

    for (final entry in _entries) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );

      if (entryDate == targetDate) {
        return entry;
      }
    }

    return null;
  }

  List<FlSpot> _createSpots() {
    final spots = <FlSpot>[];

    for (int i = 0; i < 7; i++) {
      final entry = _entryForDay(i);

      if (entry != null) {
        spots.add(
          FlSpot(
            i.toDouble(),
            entry.weight,
          ),
        );
      }
    }

    return spots;
  }

  double _getMinY() {
    if (_entries.isEmpty) {
      return 0;
    }

    final weights =
        _entries.map((e) => e.weight).toList();

    final minWeight =
        weights.reduce((a, b) => a < b ? a : b);

    return (minWeight - 2).clamp(
      0,
      double.infinity,
    );
  }

  double _getMaxY() {
    if (_entries.isEmpty) {
      return 100;
    }

    final weights =
        _entries.map((e) => e.weight).toList();

    final maxWeight =
        weights.reduce((a, b) => a > b ? a : b);

    return maxWeight + 2;
  }

  String _dayLabel(int index) {
    final today = DateTime.now();

    final date = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(
      Duration(days: 6 - index),
    );

    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return days[date.weekday - 1];
  }

  String _dateLabel(int index) {
    final today = DateTime.now();

    final date = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(
      Duration(days: 6 - index),
    );

    return '${date.day}/${date.month}';
  }

  double? _getChange() {
    if (_entries.length < 2) {
      return null;
    }

    final first = _entries.first.weight;
    final last = _entries.last.weight;

    return last - first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weight History',
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: _buildContent(),
            ),
    );
  }

  Widget _buildContent() {
    if (_entries.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),

          const Icon(
            Icons.monitor_weight_outlined,
            size: 72,
          ),

          const SizedBox(height: 20),

          const Text(
            'No weight data yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Update your weight to start tracking your progress.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      );
    }

    final change = _getChange();

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Last 7 Days',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Track your weight progress throughout the week.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium,
        ),

        const SizedBox(height: 24),

        // SUMMARY
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Entries',
                value: '${_entries.length}',
                icon: Icons.calendar_today,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _SummaryCard(
                title: 'Change',
                value: change == null
                    ? '--'
                    : '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} KG',
                icon: Icons.trending_down,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // GRAPH
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              12,
              24,
              20,
              20,
            ),
            child: SizedBox(
              height: 320,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 6,

                  minY: _getMinY(),
                  maxY: _getMaxY(),

                  gridData: const FlGridData(
                    show: true,
                  ),

                  borderData: FlBorderData(
                    show: false,
                  ),

                  titlesData: FlTitlesData(
                    topTitles:
                        const AxisTitles(
                      sideTitles:
                          SideTitles(
                        showTitles: false,
                      ),
                    ),

                    rightTitles:
                        const AxisTitles(
                      sideTitles:
                          SideTitles(
                        showTitles: false,
                      ),
                    ),

                    leftTitles:
                        const AxisTitles(
                      sideTitles:
                          SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                      ),
                    ),

                    bottomTitles:
                        AxisTitles(
                      sideTitles:
                          SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 42,
                        getTitlesWidget:
                            (value, meta) {
                          final index =
                              value.toInt();

                          if (index < 0 ||
                              index > 6) {
                            return const SizedBox();
                          }

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              top: 8,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _dayLabel(index),
                                  style:
                                      const TextStyle(
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _dateLabel(index),
                                  style:
                                      const TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  lineTouchData:
                      LineTouchData(
                    enabled: true,
                    touchTooltipData:
                        LineTouchTooltipData(
                      getTooltipItems:
                          (spots) {
                        return spots.map(
                          (spot) {
                            return LineTooltipItem(
                              '${spot.y.toStringAsFixed(1)} KG',
                              const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            );
                          },
                        ).toList();
                      },
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      spots: _createSpots(),

                      isCurved: true,

                      barWidth: 4,

                      dotData:
                          const FlDotData(
                        show: true,
                      ),

                      belowBarData:
                          BarAreaData(
                        show: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // DATA LIST
        const Text(
          'Recorded Weights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ..._entries.reversed.map(
          (entry) {
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(
                    Icons.monitor_weight,
                  ),
                ),
                title: Text(
                  '${entry.weight.toStringAsFixed(1)} ${entry.unit}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(icon),

            const SizedBox(height: 10),

            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}