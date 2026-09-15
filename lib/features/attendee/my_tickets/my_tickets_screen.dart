import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/models/booking.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/repositories/booking_repository.dart';

class MyTicketsScreen extends ConsumerStatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  ConsumerState<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends ConsumerState<MyTicketsScreen> {
  Future<void> _requestRefund(BuildContext context, Booking booking) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Request Refund'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Booking: ${booking.id.substring(0, 8)}...',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
      await ref.read(bookingRepositoryProvider).requestRefund(booking.id, booking.totalAmount.toDouble(), reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refund request submitted. The organizer will review it.')),
        );
        setState(() {}); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authControllerProvider).value!;

    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
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
            return const Center(child: Text('You have no tickets.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              final canRefund = b.status == 'confirmed';
              
              Color statusColor = Colors.grey;
              if (b.status == 'confirmed') statusColor = Colors.green;
              if (b.status == 'checked_in') statusColor = Colors.blue;
              if (b.status == 'cancelled' || b.status == 'refunded') statusColor = Colors.red;
              if (b.status == 'pending_payment') statusColor = Colors.orange;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.qr_code, size: 40),
                  title: Text('Booking #${b.id.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(b.status.toUpperCase(),
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      Text('Qty: ${b.quantity}  •  Total: \$${b.totalAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canRefund)
                        IconButton(
                          icon: const Icon(Icons.money_off, color: Colors.orange),
                          tooltip: 'Request Refund',
                          onPressed: () => _requestRefund(context, b),
                        ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    if (b.status == 'confirmed' || b.status == 'pending_payment') {
                      context.push('/attendee/ticket_qr', extra: b);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No QR available for this ticket.')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
