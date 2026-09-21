import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:eventhub/models/event_stats.dart';
import 'package:eventhub/repositories/analytics_repository.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  final String eventId;
  const AnalyticsScreen({super.key, required this.eventId});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Analytics')),
      body: FutureBuilder<EventStats>(
        future: ref
            .read(analyticsRepositoryProvider)
            .getEventStats(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stats = snapshot.data;
          if (stats == null) {
            return const Center(child: Text('No stats available.'));
          }

          final nonAttended = stats.ticketsSold - stats.attended;
          final hasData = stats.ticketsSold > 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  stats.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Revenue',
                        '\$${stats.revenue.toStringAsFixed(2)}',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Tickets Sold',
                        '${stats.ticketsSold}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Checked In', '${stats.attended}'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Attendance',
                        '${stats.attendanceRate}%',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),
                Text(
                  'Attendance Breakdown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                if (hasData)
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: stats.attended.toDouble(),
                            title: '${stats.attended}\nAttended',
                            radius: 100,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.grey.shade400,
                            value: nonAttended.toDouble(),
                            title: '$nonAttended\nAbsent',
                            radius: 100,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 0,
                      ),
                    ),
                  )
                else
                  const Center(
                    child: Text('No tickets sold yet to show breakdown.'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
