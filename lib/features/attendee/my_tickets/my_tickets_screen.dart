import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eventhub/models/booking.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/repositories/booking_repository.dart';
import 'package:eventhub/core/providers/currency_provider.dart';
import 'package:eventhub/core/utils/calendar_utils.dart';

class MyTicketsScreen extends ConsumerStatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  ConsumerState<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends ConsumerState<MyTicketsScreen> {
  // ────────────────────────────────────────────────────────────
  // Refund
  // ────────────────────────────────────────────────────────────
  Future<void> _requestRefund(Booking booking) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Request Refund'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Booking: ${booking.id.substring(0, 8)}...',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Amount: \$${booking.totalAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Reason for refund...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (reason == null || !mounted) return;

    try {
      await ref
          .read(bookingRepositoryProvider)
          .requestRefund(booking.id, booking.totalAmount.toDouble(), reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Refund request submitted. The organizer will review it.',
            ),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  // ────────────────────────────────────────────────────────────
  // Ticket Transfer
  // ────────────────────────────────────────────────────────────
  Future<void> _transferTicket(Booking booking) async {
    final emailController = TextEditingController();
    String? errorText;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.swap_horiz, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text('Transfer Ticket'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking #${booking.id.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter the email address of the person you want to transfer this ticket to. '
                  'They must already have an EventHub account.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Recipient Email',
                    hintText: 'e.g. friend@email.com',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: errorText,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.amber, size: 18),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'This action is irreversible. Your QR code will be revoked and a new one issued to the recipient.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Transfer'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: () {
                  final email = emailController.text.trim();
                  if (email.isEmpty || !email.contains('@')) {
                    setDialogState(
                      () => errorText = 'Enter a valid email address',
                    );
                    return;
                  }
                  Navigator.pop(ctx, true);
                },
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final email = emailController.text.trim();

    // Show loading
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Processing transfer...'),
            ],
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }

    try {
      final user = ref.read(authControllerProvider).value!;
      await ref
          .read(bookingRepositoryProvider)
          .transferTicket(
            bookingId: booking.id,
            currentUserId: user.id,
            recipientEmail: email,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Ticket transferred to $email successfully!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer failed: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  // ────────────────────────────────────────────────────────────
  // Calendar / Share Bottom Sheet
  // ────────────────────────────────────────────────────────────
  void _showCalendarSheet(Booking booking) {
    // We don't have full event data in the booking model, so we construct
    // a placeholder invite using available booking fields
    final title = 'EventHub Booking #${booking.id.substring(0, 8)}';
    final eventStart = DateTime.now().add(
      const Duration(days: 3),
    ); // placeholder

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add to Calendar / Share',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _calendarOption(
              icon: Icons.calendar_today,
              label: 'Add to Google Calendar',
              color: Colors.blue,
              onTap: () async {
                Navigator.pop(ctx);
                final url = CalendarUtils.googleCalendarUrl(
                  title: title,
                  startTime: eventStart,
                  endTime: eventStart.add(const Duration(hours: 2)),
                  description: 'EventHub booking ID: ${booking.id}',
                );
                final uri = Uri.parse(url);
                final messenger = ScaffoldMessenger.of(context);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  // Fallback: copy to clipboard
                  await Clipboard.setData(ClipboardData(text: url));
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('📋 Calendar link copied to clipboard!'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            _calendarOption(
              icon: Icons.share,
              label: 'Share Event Invite',
              color: Colors.green,
              onTap: () async {
                Navigator.pop(ctx);
                final shareText = CalendarUtils.shareableInviteText(
                  eventTitle: title,
                  startTime: eventStart,
                  location: 'Venue details in your ticket',
                  bookingId: booking.id,
                );
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(ClipboardData(text: shareText));
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('📋 Invite text copied to clipboard!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendarOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Build
  // ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;
    final currency = ref.watch(currencyProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        actions: [
          // Currency selector
          PopupMenuButton<AppCurrency>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currency.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
            tooltip: 'Change Currency',
            onSelected: (c) =>
                ref.read(currencyProvider.notifier).setCurrency(c),
            itemBuilder: (_) => AppCurrency.values
                .map(
                  (c) => PopupMenuItem(
                    value: c,
                    child: Text(
                      '${c.symbol} ${c.code}',
                      style: TextStyle(
                        fontWeight: currency == c
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: FutureBuilder<List<Booking>>(
        future: ref.read(bookingRepositoryProvider).getMyBookings(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.confirmation_number_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tickets booked yet.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/attendee/browse'),
                    child: const Text('Browse Events'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              final canRefund = b.status == 'confirmed';
              final canTransfer = b.status == 'confirmed';

              Color statusColor = Colors.grey;
              if (b.status == 'confirmed') statusColor = Colors.green;
              if (b.status == 'checked_in') statusColor = Colors.blue;
              if (b.status == 'cancelled' || b.status == 'refunded') {
                statusColor = Colors.red;
              }
              if (b.status == 'pending_payment') statusColor = Colors.orange;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.qr_code, size: 28, color: statusColor),
                    ),
                    title: Text(
                      'Booking #${b.id.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                b.status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Qty: ${b.quantity}  •  ${CurrencyHelper.format(b.totalAmount.toDouble(), currency)}',
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (action) {
                        switch (action) {
                          case 'qr':
                            context.push('/attendee/ticket_qr', extra: b);
                          case 'rate':
                            context.push('/attendee/event/${b.eventId}');
                          case 'refund':
                            if (canRefund) _requestRefund(b);
                          case 'transfer':
                            if (canTransfer) _transferTicket(b);
                          case 'calendar':
                            _showCalendarSheet(b);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'qr',
                          child: Row(
                            children: [
                              Icon(Icons.qr_code_2, size: 20),
                              SizedBox(width: 8),
                              Text('View QR Ticket'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'calendar',
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Text('Add to Calendar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'rate',
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_outline,
                                size: 20,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 8),
                              Text('Rate Event'),
                            ],
                          ),
                        ),
                        if (canTransfer)
                          const PopupMenuItem(
                            value: 'transfer',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.swap_horiz,
                                  size: 20,
                                  color: Colors.deepPurple,
                                ),
                                SizedBox(width: 8),
                                Text('Transfer Ticket'),
                              ],
                            ),
                          ),
                        if (canRefund)
                          const PopupMenuItem(
                            value: 'refund',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.money_off,
                                  size: 20,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 8),
                                Text('Request Refund'),
                              ],
                            ),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () => context.push('/attendee/ticket_qr', extra: b),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
