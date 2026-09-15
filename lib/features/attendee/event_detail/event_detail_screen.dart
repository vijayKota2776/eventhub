import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/providers/event_provider.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/repositories/event_repository.dart';
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
  late Future<List<Map<String, dynamic>>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _checkWaitlist();
    _loadReviews();
  }

  void _loadReviews() {
    _reviewsFuture = ref.read(eventRepositoryProvider).getEventReviews(widget.eventId);
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
        if (mounted) {
          setState(() => _onWaitlist = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Left waitlist.')));
        }
      } else {
        await repo.joinWaitlist(widget.eventId, user.id);
        if (mounted) {
          setState(() => _onWaitlist = true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You're on the waitlist! We'll notify you when tickets open up.")));
        }
      }
    } finally {
      if (mounted) setState(() => _waitlistLoading = false);
    }
  }

  void _showReviewDialog() {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              title: const Text('Leave a Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('How was your experience?'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        icon: Icon(
                          star <= selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() => selectedRating = star);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share feedback about venue, speakers, organization...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final user = ref.read(authControllerProvider).value;
                    if (user == null) return;

                    Navigator.pop(dialogContext);
                    try {
                      await ref.read(eventRepositoryProvider).submitReview(
                        eventId: widget.eventId,
                        userId: user.id,
                        userName: user.name ?? user.email.split('@').first,
                        rating: selectedRating,
                        comment: commentController.text.trim().isNotEmpty 
                            ? commentController.text.trim() 
                            : null,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('⭐ Review submitted! Thank you.')),
                        );
                        setState(() {
                          _loadReviews();
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
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
                      ? Image.network(
                          event.bannerUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholder(colorScheme),
                        )
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
                            child: Text(
                              event.category.toUpperCase(),
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _reviewsFuture,
                            builder: (context, snapshot) {
                              final reviews = snapshot.data ?? [];
                              if (reviews.isEmpty) return const SizedBox();
                              final avg = reviews.fold<double>(0, (s, r) => s + (r['rating'] as num).toDouble()) / reviews.length;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${avg.toStringAsFixed(1)} (${reviews.length})',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (isSoldOut) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'SOLD OUT',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow(
                        context,
                        icon: Icons.calendar_today,
                        title: dateFormat.format(event.startAt),
                        subtitle: '${timeFormat.format(event.startAt)} - ${timeFormat.format(event.endAt)}',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(context, icon: Icons.location_on, title: event.venue, subtitle: event.city),
                      const SizedBox(height: 32),
                      Text('About Event', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(
                        event.description ?? 'No description available.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 32),

                      // Reviews & Ratings Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Reviews & Ratings', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            icon: const Icon(Icons.rate_review_outlined, size: 18),
                            label: const Text('Add Review'),
                            onPressed: _showReviewDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _reviewsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                          }
                          final reviews = snapshot.data ?? [];
                          if (reviews.isEmpty) {
                            return Card(
                              elevation: 0,
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: Text('No reviews yet. Be the first to share your thoughts!', style: TextStyle(color: Colors.grey)),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: reviews.map((r) {
                              final name = (r['user_name'] ?? 'Attendee').toString();
                              final rating = (r['rating'] as num?)?.toInt() ?? 5;
                              final comment = r['comment'] as String?;
                              final date = r['created_at'] != null ? r['created_at'].toString().substring(0, 10) : '';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Row(
                                            children: List.generate(5, (starIdx) {
                                              return Icon(
                                                starIdx < rating ? Icons.star : Icons.star_border,
                                                color: Colors.amber,
                                                size: 16,
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                      if (comment != null && comment.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(comment, style: const TextStyle(fontSize: 14)),
                                      ],
                                      const SizedBox(height: 6),
                                      Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

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
