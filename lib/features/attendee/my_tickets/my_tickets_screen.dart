import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/models/booking.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/repositories/booking_repository.dart';

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.qr_code, size: 40),
                  title: Text('Booking ID: ${b.id.substring(0, 8)}...'),
                  subtitle: Text('Status: ${b.status}\nQty: ${b.quantity}'),
                  trailing: const Icon(Icons.chevron_right),
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
