import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/repositories/booking_repository.dart';
import 'package:eventhub/models/ticket_type.dart';
import 'package:eventhub/repositories/event_repository.dart';
import 'package:eventhub/core/providers/currency_provider.dart';

class GroupBookingScreen extends ConsumerStatefulWidget {
  final String eventId;
  const GroupBookingScreen({super.key, required this.eventId});

  @override
  ConsumerState<GroupBookingScreen> createState() => _GroupBookingScreenState();
}

class _GroupBookingScreenState extends ConsumerState<GroupBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  TicketType? _selectedTier;
  bool _isLoading = false;

  // Each attendee has a name + email controller
  final List<Map<String, TextEditingController>> _attendees = [];

  @override
  void initState() {
    super.initState();
    _addAttendee(); // Start with 1
  }

  void _addAttendee() {
    setState(() {
      _attendees.add({
        'name': TextEditingController(),
        'email': TextEditingController(),
      });
    });
  }

  void _removeAttendee(int index) {
    if (_attendees.length <= 1) return;
    setState(() {
      _attendees[index]['name']!.dispose();
      _attendees[index]['email']!.dispose();
      _attendees.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (final a in _attendees) {
      a['name']!.dispose();
      a['email']!.dispose();
    }
    super.dispose();
  }

  double get _totalPrice {
    if (_selectedTier == null) return 0;
    return _selectedTier!.price * _attendees.length;
  }

  Future<void> _bookGroup() async {
    if (!_formKey.currentState!.validate() || _selectedTier == null) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authControllerProvider).value!;
      final currency = ref.read(currencyProvider);

      final attendeeList = _attendees
          .map(
            (a) => {
              'name': a['name']!.text.trim(),
              'email': a['email']!.text.trim(),
            },
          )
          .toList();

      final bookingIds = await ref
          .read(bookingRepositoryProvider)
          .bookGroupTickets(
            ticketTypeId: _selectedTier!.id,
            userId: user.id,
            eventId: widget.eventId,
            attendees: attendeeList,
          );

      if (mounted) {
        context.pushReplacement(
          '/attendee/event/${widget.eventId}/group_tickets',
          extra: {
            'bookingIds': bookingIds,
            'attendees': attendeeList,
            'tierName': _selectedTier!.name,
            'totalPrice': _totalPrice,
            'currency': currency,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Booking failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Booking'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                '${_attendees.length} attendee${_attendees.length > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12),
              ),
              avatar: const Icon(Icons.group, size: 16),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<TicketType>>(
        future: ref
            .read(eventRepositoryProvider)
            .getTicketTypes(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tiers = snapshot.data ?? [];

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Info Banner ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.group, color: Colors.deepPurple, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Each attendee gets their own individual QR-code ticket.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Ticket Tier ──────────────────────────────────────
                Text(
                  'Select Ticket Tier',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...tiers.map((t) {
                  final remaining = t.quantityTotal - t.quantitySold;
                  final isAvailable = remaining >= _attendees.length;
                  final isSelected = _selectedTier?.id == t.id;
                  return Card(
                    elevation: isSelected ? 3 : 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        t.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${CurrencyHelper.format(t.price, currency)} per person  •  $remaining available',
                        style: TextStyle(
                          color: isAvailable ? null : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: colorScheme.primary)
                          : null,
                      enabled: isAvailable,
                      onTap: isAvailable
                          ? () => setState(() => _selectedTier = t)
                          : null,
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // ── Attendees ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendee Details',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Add'),
                      onPressed:
                          _selectedTier != null &&
                              _attendees.length <
                                  (_selectedTier!.quantityTotal -
                                      _selectedTier!.quantitySold)
                          ? _addAttendee
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._attendees.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final a = entry.value;
                  return _AttendeeCard(
                    index: idx,
                    nameController: a['name']!,
                    emailController: a['email']!,
                    onRemove: _attendees.length > 1
                        ? () => _removeAttendee(idx)
                        : null,
                  );
                }),
                const SizedBox(height: 24),

                // ── Price Summary ────────────────────────────────────
                if (_selectedTier != null) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_attendees.length} × ${CurrencyHelper.format(_selectedTier!.price, currency)}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        CurrencyHelper.format(_totalPrice, currency),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            icon: _isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.group),
            label: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Book for ${_attendees.length} — ${CurrencyHelper.format(_totalPrice, ref.watch(currencyProvider))}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
            onPressed: (_selectedTier != null && !_isLoading)
                ? _bookGroup
                : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Attendee Input Card
// ─────────────────────────────────────────────────────────────────────────────
class _AttendeeCard extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final VoidCallback? onRemove;

  const _AttendeeCard({
    required this.index,
    required this.nameController,
    required this.emailController,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Attendee ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: onRemove,
                    tooltip: 'Remove attendee',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'Valid email required'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
