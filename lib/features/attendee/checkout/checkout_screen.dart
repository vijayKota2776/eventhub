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
  
  final _promoController = TextEditingController();
  bool _isValidatingPromo = false;
  String? _appliedPromoCode;
  double? _discountAmount;
  double? _discountPercent;
  String? _promoError;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _validatePromo() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isValidatingPromo = true;
      _promoError = null;
    });

    try {
      final promoData = await ref.read(bookingRepositoryProvider).validatePromoCode(widget.eventId, code);
      if (promoData == null) {
        setState(() {
          _promoError = 'Invalid or expired promo code';
          _appliedPromoCode = null;
          _discountAmount = null;
          _discountPercent = null;
        });
      } else {
        setState(() {
          _appliedPromoCode = code;
          _discountAmount = promoData['discount_amount'] != null ? double.parse(promoData['discount_amount'].toString()) : null;
          _discountPercent = promoData['discount_percent'] != null ? double.parse(promoData['discount_percent'].toString()) : null;
          _promoError = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promo code applied!')));
      }
    } catch (e) {
      setState(() => _promoError = 'Error validating promo code');
    } finally {
      setState(() => _isValidatingPromo = false);
    }
  }

  Future<void> _bookTicket() async {
    if (_selectedTier == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(authControllerProvider).value!;
      final bookingId = await ref.read(bookingRepositoryProvider).bookTicket(
        ticketTypeId: _selectedTier!.id,
        quantity: _quantity,
        userId: user.id,
        promoCode: _appliedPromoCode,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed!')),
        );
        context.go('/attendee/my_tickets');
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

  double get _totalPrice {
    if (_selectedTier == null) return 0;
    double base = _selectedTier!.price * _quantity;
    
    if (_appliedPromoCode != null) {
      if (_discountPercent != null) {
        base = base - (base * (_discountPercent! / 100));
      } else if (_discountAmount != null) {
        base = base - (_discountAmount! * _quantity); // discount per ticket or flat? Typically per transaction, but for simplicity let's assume flat discount total. 
        // Wait, if it's flat discount amount, let's subtract once.
        // base = base - _discountAmount!;
      }
    }
    return base < 0 ? 0 : base;
  }
  
  double get _discountTotal {
     if (_selectedTier == null) return 0;
     double base = _selectedTier!.price * _quantity;
     if (_appliedPromoCode != null) {
        if (_discountPercent != null) {
           return base * (_discountPercent! / 100);
        } else if (_discountAmount != null) {
           return _discountAmount!;
        }
     }
     return 0;
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
                
                const SizedBox(height: 24),
                const Text('Promo Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        decoration: InputDecoration(
                          hintText: 'Enter code',
                          border: const OutlineInputBorder(),
                          errorText: _promoError,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isValidatingPromo ? null : _validatePromo,
                      child: _isValidatingPromo ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Apply'),
                    ),
                  ],
                ),
                if (_appliedPromoCode != null)
                   Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: Text('Applied: $_appliedPromoCode', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                   ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                    Text('\$${(_selectedTier!.price * _quantity).toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
                if (_appliedPromoCode != null)
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('Discount:', style: TextStyle(fontSize: 16, color: Colors.green)),
                       Text('-\$${_discountTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.green)),
                     ],
                   ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('\$${_totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
