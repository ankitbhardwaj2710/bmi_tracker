import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/weight_entry.dart';
import '../../services/firestore_service.dart';

class WeightHistoryScreen extends StatefulWidget {
  const WeightHistoryScreen({
    super.key,
  });

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

      final sevenDaysAgo = today.subtract(
        const Duration(days: 6),
      );

      final filtered = history.where((entry) {
        final entryDate = DateTime(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        );

        return !entryDate.isBefore(
          sevenDaysAgo,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _entries = filtered;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Weight history error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  List<FlSpot> _createSpots() {
    return List.generate(
      _entries.length,
      (index) {
        return FlSpot(
          index.toDouble(),
          _entries[index].weight,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weight History',
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_entries.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            Center(
              child: Text(
                'No weight data for the last 7 days.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Last 7 Days',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your weight progress over the past week.',
            ),

            const SizedBox(height: 30),

            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (_entries.length - 1)
                      .toDouble(),

                  gridData: const FlGridData(
                    show: true,
                  ),

                  titlesData: FlTitlesData(
                    bottomTitles:
                        AxisTitles(
                      sideTitles:
                          SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget:
                            (value, meta) {
                          final index =
                              value.toInt();

                          if (index < 0 ||
                              index >=
                                  _entries.length) {
                            return const SizedBox();
                          }

                          final date =
                              _entries[index].date;

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              top: 8,
                            ),
                            child: Text(
                              '${date.day}/${date.month}',
                              style:
                                  const TextStyle(
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
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
          ],
        ),
      ),
    );
  }
}