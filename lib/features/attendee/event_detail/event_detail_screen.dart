import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/providers/event_provider.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/repositories/waitlist_repository.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool? _onWaitlist;
  bool _waitlistLoading = false;

  @override
  void initState() {
    super.initState();
    _checkWaitlist();
  }

  Future<void> _checkWaitlist() async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;
    final on = await ref.read(waitlistRepositoryProvider).isOnWaitlist(widget.eventId, user.id);
    if (mounted) setState(() => _onWaitlist = on);
  }

  Future<void> _toggleWaitlist() async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;
    setState(() => _waitlistLoading = true);
    try {
      final repo = ref.read(waitlistRepositoryProvider);
      if (_onWaitlist == true) {
        await repo.leaveWaitlist(widget.eventId, user.id);
        if (mounted) setState(() => _onWaitlist = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Left waitlist.')));
      } else {
        await repo.joinWaitlist(widget.eventId, user.id);
        if (mounted) setState(() => _onWaitlist = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You're on the waitlist! We'll notify you when tickets open up.")));
      }
    } finally {
      if (mounted) setState(() => _waitlistLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (event) {
          final dateFormat = DateFormat('EEEE, MMMM d, y');
          final timeFormat = DateFormat('h:mm a');
          final isSoldOut = event.totalSold >= 0 && event.status == 'sold_out';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: event.bannerUrl != null && event.bannerUrl!.isNotEmpty
                      ? Image.network(event.bannerUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme))
                      : _buildPlaceholder(colorScheme),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(event.category.toUpperCase(),
                                style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                          ),
                          if (isSoldOut) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(16)),
                              child: const Text('SOLD OUT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(event.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      _buildInfoRow(context, icon: Icons.calendar_today,
                          title: dateFormat.format(event.startAt),
                          subtitle: '${timeFormat.format(event.startAt)} - ${timeFormat.format(event.endAt)}'),
                      const SizedBox(height: 16),
                      _buildInfoRow(context, icon: Icons.location_on, title: event.venue, subtitle: event.city),
                      const SizedBox(height: 32),
                      Text('About Event',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(event.description ?? 'No description available.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: eventAsync.hasValue
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: eventAsync.value!.status == 'sold_out'
                    ? ElevatedButton.icon(
                        onPressed: _waitlistLoading ? null : _toggleWaitlist,
                        icon: _waitlistLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Icon(_onWaitlist == true ? Icons.notifications_off : Icons.notifications_active),
                        label: Text(_onWaitlist == true ? 'Leave Waitlist' : 'Join Waitlist'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _onWaitlist == true ? Colors.grey : Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => context.push('/attendee/event/${widget.eventId}/checkout'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Book Ticket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              ),
            )
          : null,
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.secondaryContainer,
      child: Icon(Icons.event, size: 64, color: colorScheme.onSecondaryContainer),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: colorScheme.onSecondaryContainer),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
