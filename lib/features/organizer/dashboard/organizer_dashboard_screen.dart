import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/repositories/event_repository.dart';
import 'package:eventhub/models/event.dart';
import 'package:eventhub/features/organizer/scanner/scanner_screen.dart';
import 'package:intl/intl.dart';

class OrganizerDashboardScreen extends ConsumerStatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  ConsumerState<OrganizerDashboardScreen> createState() =>
      _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState
    extends ConsumerState<OrganizerDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authControllerProvider).value;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Dashboard'),
        actions: [
          // Payouts shortcut
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Payouts',
            onPressed: () => context.push('/organizer/payouts'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: _currentIndex == 0
          ? FutureBuilder<List<Event>>(
              future: ref
                  .read(eventRepositoryProvider)
                  .getEventsByOrganizer(user!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final events = snapshot.data ?? [];

                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note,
                            size: 64, color: colorScheme.outline),
                        const SizedBox(height: 16),
                        const Text('No events created yet.',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Create New Event'),
                          onPressed: () =>
                              context.push('/organizer/create_event'),
                        ),
                      ],
                    ),
                  );
                }

                // Revenue summary
                final totalRevenue = events.fold<double>(
                    0, (sum, e) => sum + e.grossRevenue.toDouble());
                final totalSold =
                    events.fold<int>(0, (sum, e) => sum + e.totalSold);

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ── Summary strip ──────────────────────────
                      Row(
                        children: [
                          _SummaryTile(
                            label: 'Events',
                            value: '${events.length}',
                            icon: Icons.event,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          _SummaryTile(
                            label: 'Tickets Sold',
                            value: '$totalSold',
                            icon: Icons.confirmation_number,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          _SummaryTile(
                            label: 'Revenue',
                            value:
                                '\$${totalRevenue.toStringAsFixed(0)}',
                            icon: Icons.attach_money,
                            color: Colors.green,
                            onTap: () =>
                                context.push('/organizer/payouts'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // ── Event list ─────────────────────────────
                      ...events.map((event) => _EventTile(event: event)),
                    ],
                  ),
                );
              },
            )
          : _currentIndex == 1
              ? const ScannerScreen()
              : const SizedBox(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/organizer/create_event'),
              icon: const Icon(Icons.add),
              label: const Text('New Event'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Tile
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color)),
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Event Tile with action buttons
// ─────────────────────────────────────────────────────────────────────────────
class _EventTile extends StatelessWidget {
  final Event event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (event.status == 'published') statusColor = Colors.green;
    if (event.status == 'draft') statusColor = Colors.orange;
    if (event.status == 'rejected') statusColor = Colors.red;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(event.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.status.toUpperCase(),
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM d, y').format(event.startAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${event.totalSold} sold  •  \$${event.grossRevenue.toStringAsFixed(0)} revenue',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Action row
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ActionBtn(
                    icon: Icons.analytics_outlined,
                    label: 'Analytics',
                    color: Colors.blue,
                    onTap: () => context
                        .push('/organizer/event/${event.id}/analytics'),
                  ),
                  _ActionBtn(
                    icon: Icons.people_outlined,
                    label: 'Attendees',
                    color: Colors.orange,
                    onTap: () => context
                        .push('/organizer/event/${event.id}/attendees'),
                  ),
                  _ActionBtn(
                    icon: Icons.local_offer_outlined,
                    label: 'Promo',
                    color: Colors.purple,
                    onTap: () =>
                        context.push('/organizer/event/${event.id}/promo'),
                  ),
                  _ActionBtn(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Tiers',
                    color: Colors.teal,
                    onTap: () => context
                        .push('/organizer/event/${event.id}/tickets'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(icon, size: 16, color: color),
      label: Text(label,
          style: TextStyle(fontSize: 12, color: color)),
      onPressed: onTap,
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
    );
  }
}
