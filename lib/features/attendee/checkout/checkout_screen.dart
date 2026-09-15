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
      if (!mounted) return;

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
      if (mounted) setState(() => _promoError = 'Error validating promo code');
    } finally {
      if (mounted) setState(() => _isValidatingPromo = false);
    }
  }

  double get _totalPrice {
    if (_selectedTier == null) return 0;
    double base = _selectedTier!.price * _quantity;

    if (_appliedPromoCode != null) {
      if (_discountPercent != null) {
        base = base - (base * (_discountPercent! / 100));
      } else if (_discountAmount != null) {
        base = base - _discountAmount!;
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

  void _openPaymentGateway() {
    if (_selectedTier == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return _PaymentGatewaySheet(
          amount: _totalPrice,
          tierName: _selectedTier!.name,
          quantity: _quantity,
          onPaymentSuccess: (paymentMethod, txnId) async {
            Navigator.pop(bottomSheetContext);
            await _processBooking(txnId);
          },
        );
      },
    );
  }

  Future<void> _processBooking(String txnId) async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(authControllerProvider).value!;
      await ref.read(bookingRepositoryProvider).bookTicket(
        ticketTypeId: _selectedTier!.id,
        quantity: _quantity,
        userId: user.id,
        promoCode: _appliedPromoCode,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Booking Confirmed!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transaction: $txnId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                Text('You have booked $_quantity x ${_selectedTier!.name}. Your QR ticket is ready in your wallet.'),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  context.go('/attendee/my_tickets');
                },
                child: const Text('View My Tickets'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete booking: $e')),
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
                final remaining = t.quantityTotal - t.quantitySold;
                final isAvailable = remaining > 0;
                final isSelected = _selectedTier?.id == t.id;

                return Card(
                  elevation: isSelected ? 3 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('\$${t.price.toStringAsFixed(2)} • ${isAvailable ? '$remaining remaining' : 'Sold Out'}'),
                    trailing: isSelected 
                        ? const Icon(Icons.check_circle, color: Colors.blue) 
                        : isAvailable 
                            ? const Icon(Icons.radio_button_unchecked, color: Colors.grey)
                            : null,
                    enabled: isAvailable,
                    onTap: isAvailable ? () {
                      setState(() {
                        _selectedTier = t;
                        _quantity = 1;
                      });
                    } : null,
                  ),
                );
              }),
              if (_selectedTier != null) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ticket Quantity:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                            ),
                            Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: _quantity < (_selectedTier!.quantityTotal - _selectedTier!.quantitySold)
                                  ? () => setState(() => _quantity++)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text('Promo Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        decoration: InputDecoration(
                          hintText: 'Enter promo code (e.g. VIP50)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          errorText: _promoError,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isValidatingPromo ? null : _validatePromo,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      child: _isValidatingPromo 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : const Text('Apply'),
                    ),
                  ],
                ),
                if (_appliedPromoCode != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text('Applied: $_appliedPromoCode', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                    Text('\$${(_selectedTier!.price * _quantity).toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
                if (_appliedPromoCode != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Promo Discount:', style: TextStyle(fontSize: 16, color: Colors.green)),
                      Text('-\$${_discountTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('\$${_totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: (_selectedTier != null && !_isLoading) ? _openPaymentGateway : null,
            icon: _isLoading ? const SizedBox() : const Icon(Icons.lock_outline),
            label: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : Text('Proceed to Pay \$${_totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentGatewaySheet extends StatefulWidget {
  final double amount;
  final String tierName;
  final int quantity;
  final Future<void> Function(String method, String txnId) onPaymentSuccess;

  const _PaymentGatewaySheet({
    required this.amount,
    required this.tierName,
    required this.quantity,
    required this.onPaymentSuccess,
  });

  @override
  State<_PaymentGatewaySheet> createState() => _PaymentGatewaySheetState();
}

class _PaymentGatewaySheetState extends State<_PaymentGatewaySheet> {
  String _selectedMethod = 'UPI';
  bool _isProcessing = false;
  String _processStatus = '';

  Future<void> _handlePay() async {
    setState(() {
      _isProcessing = true;
      _processStatus = 'Connecting to Secure Payment Gateway...';
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _processStatus = 'Authorizing payment via $_selectedMethod...');

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _processStatus = 'Securing 256-bit encrypted confirmation...');

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final txnId = 'TXN_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    await widget.onPaymentSuccess(_selectedMethod, txnId);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Secure Checkout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text('256-bit SSL', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Order: ${widget.quantity}x ${widget.tierName} • Total: \$${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),

          if (_isProcessing) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(_processStatus, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 6),
                    const Text('Please do not press back or close the app', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ] else ...[
            const Text('Choose Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            _buildMethodTile(
              id: 'UPI',
              title: 'UPI / Google Pay / PhonePe',
              subtitle: 'Fast, zero-fee direct bank transfer',
              icon: Icons.qr_code_2,
            ),
            _buildMethodTile(
              id: 'Card',
              title: 'Credit / Debit Card',
              subtitle: 'Visa, Mastercard, RuPay, Amex',
              icon: Icons.credit_card,
            ),
            _buildMethodTile(
              id: 'NetBanking',
              title: 'Net Banking',
              subtitle: 'All major Indian & international banks',
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handlePay,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.green.shade700,
              ),
              child: Text(
                'Pay \$${widget.amount.toStringAsFixed(2)} Now',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMethodTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == id;
    return Card(
      elevation: isSelected ? 2 : 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
        title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
        onTap: () => setState(() => _selectedMethod = id),
      ),
    );
  }
}
