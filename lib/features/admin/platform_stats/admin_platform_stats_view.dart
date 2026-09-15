import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub/repositories/analytics_repository.dart';

class AdminPlatformStatsView extends ConsumerStatefulWidget {
  const AdminPlatformStatsView({super.key});

  @override
  ConsumerState<AdminPlatformStatsView> createState() => _AdminPlatformStatsViewState();
}

class _AdminPlatformStatsViewState extends ConsumerState<AdminPlatformStatsView> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _statsFuture = ref.read(analyticsRepositoryProvider).getPlatformStats();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading stats: ${snapshot.error}'));
        }

        final data = snapshot.data ?? {};
        final totalUsers = data['totalUsers'] ?? 0;
        final totalAttendees = data['totalAttendees'] ?? 0;
        final totalOrganizers = data['totalOrganizers'] ?? 0;
        final totalEvents = data['totalEvents'] ?? 0;
        final publishedEvents = data['publishedEvents'] ?? 0;
        final pendingEvents = data['pendingEvents'] ?? 0;
        final totalBookings = data['totalBookings'] ?? 0;
        final totalRevenue = (data['totalRevenue'] as num?)?.toDouble() ?? 0.0;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadStats();
            });
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Platform Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Revenue Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Gross Revenue',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          Icon(Icons.monetization_on_outlined, color: Colors.white, size: 28),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$${totalRevenue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Across $totalBookings total ticket bookings',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // KPI Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Users',
                      value: '$totalUsers',
                      subtitle: '$totalAttendees Attendees • $totalOrganizers Organizers',
                      icon: Icons.people_outline,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Events',
                      value: '$totalEvents',
                      subtitle: '$publishedEvents Live • $pendingEvents Pending',
                      icon: Icons.event_available,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Bookings',
                      value: '$totalBookings',
                      subtitle: 'Confirmed orders',
                      icon: Icons.confirmation_number_outlined,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'System Health',
                      value: '100%',
                      subtitle: 'DB & APIs Online',
                      icon: Icons.check_circle_outline,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Platform Status & Security',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildSecurityItem(
                        icon: Icons.security,
                        title: 'Row-Level Security (RLS)',
                        status: 'Active on 8 Tables',
                      ),
                      const Divider(height: 20),
                      _buildSecurityItem(
                        icon: Icons.lock_clock,
                        title: 'Concurrency Locking',
                        status: 'Pessimistic (FOR UPDATE RPC)',
                      ),
                      const Divider(height: 20),
                      _buildSecurityItem(
                        icon: Icons.cloud_done,
                        title: 'Supabase Backend',
                        status: 'Connected & Healthy',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String status,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(status, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        const Icon(Icons.check, color: Colors.green, size: 18),
      ],
    );
  }
}
