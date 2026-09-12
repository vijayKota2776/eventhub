import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/models/ticket_type.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/repositories/event_repository.dart';
import 'package:eventhub/repositories/booking_repository.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String eventId;
  const CheckoutScreen({super.key, required this.eventId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  TicketType? _selectedTier;
  int _quantity = 1;
  bool _isLoading = false;

  Future<void> _bookTicket() async {
    if (_selectedTier == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(authControllerProvider).value!;
      final bookingId = await ref.read(bookingRepositoryProvider).bookTicket(
        ticketTypeId: _selectedTier!.id,
        quantity: _quantity,
        userId: user.id,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed!')),
        );
        // Normally we'd go to a payment screen or success screen.
        // For MVP, we'll go back to the browse screen.
        context.go('/attendee/browse');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: FutureBuilder<List<TicketType>>(
        future: ref.read(eventRepositoryProvider).getTicketTypes(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) {
            return const Center(child: Text('No tickets available for this event.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Select Ticket Tier', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...tickets.map((t) {
                final isAvailable = (t.quantityTotal - t.quantitySold) > 0;
                return RadioListTile<TicketType>(
                  title: Text(t.name),
                  subtitle: Text('\$${t.price.toStringAsFixed(2)} - ${isAvailable ? 'Available' : 'Sold Out'}'),
                  value: t,
                  groupValue: _selectedTier,
                  onChanged: isAvailable ? (val) {
                    setState(() {
                      _selectedTier = val;
                      _quantity = 1;
                    });
                  } : null,
                );
              }),
              if (_selectedTier != null) ...[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quantity:', style: TextStyle(fontSize: 18)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        ),
                        Text('$_quantity', style: const TextStyle(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _quantity < (_selectedTier!.quantityTotal - _selectedTier!.quantitySold)
                              ? () => setState(() => _quantity++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('\$${(_selectedTier!.price * _quantity).toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: (_selectedTier != null && !_isLoading) ? _bookTicket : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading 
                ? const CircularProgressIndicator() 
                : const Text('Confirm & Pay', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }
}
