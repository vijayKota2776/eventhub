import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/repositories/event_repository.dart';
import 'package:eventhub/models/event.dart';
import 'package:eventhub/core/providers/currency_provider.dart';
import 'package:intl/intl.dart';

class PayoutDashboardScreen extends ConsumerStatefulWidget {
  const PayoutDashboardScreen({super.key});

  @override
  ConsumerState<PayoutDashboardScreen> createState() =>
      _PayoutDashboardScreenState();
}

class _PayoutDashboardScreenState extends ConsumerState<PayoutDashboardScreen> {
  static const double _platformFeePercent = 5.0;

  // Track which events have pending payout requests (simulated)
  final Set<String> _pendingPayouts = {};
  final Set<String> _processedPayouts = {};

  void _requestPayout(Event event) async {
    final net = _netPayout(event.grossRevenue.toDouble());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.green),
            SizedBox(width: 8),
            Text('Request Payout'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event: ${event.title}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _summaryRow(
              'Gross Revenue',
              CurrencyHelper.format(
                event.grossRevenue.toDouble(),
                AppCurrency.usd,
              ),
            ),
            _summaryRow(
              'Platform Fee ($_platformFeePercent%)',
              '- ${CurrencyHelper.format(_platformFee(event.grossRevenue.toDouble()), AppCurrency.usd)}',
            ),
            const Divider(height: 20),
            _summaryRow(
              'Net Payout',
              CurrencyHelper.format(net, AppCurrency.usd),
              bold: true,
              color: Colors.green,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm Request'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _pendingPayouts.add(event.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Payout of ${CurrencyHelper.format(net, AppCurrency.usd)} requested! Processing in 3-5 business days.',
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
      // Simulate processing after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _pendingPayouts.remove(event.id);
          _processedPayouts.add(event.id);
        });
      }
    }
  }

  double _platformFee(double gross) => gross * (_platformFeePercent / 100);
  double _netPayout(double gross) => gross - _platformFee(gross);

  Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authControllerProvider).value!;
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payout Dashboard'),
        actions: [
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
            onSelected: (c) =>
                ref.read(currencyProvider.notifier).setCurrency(c),
            itemBuilder: (_) => AppCurrency.values
                .map(
                  (c) => PopupMenuItem(
                    value: c,
                    child: Text('${c.symbol} ${c.code}'),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: ref.read(eventRepositoryProvider).getEventsByOrganizer(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data ?? [];

          // Total stats
          final totalGross = events.fold<double>(
            0,
            (sum, e) => sum + e.grossRevenue.toDouble(),
          );
          final totalNet = _netPayout(totalGross);
          final totalFee = _platformFee(totalGross);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Summary Card ─────────────────────────────────────
              Card(
                elevation: 0,
                color: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.green.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.green,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Total Earnings',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Platform: 5%',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatChip(
                            label: 'Gross',
                            value: CurrencyHelper.format(totalGross, currency),
                            color: Colors.blue,
                          ),
                          const Text(
                            '−',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                          _StatChip(
                            label: 'Fee',
                            value: CurrencyHelper.format(totalFee, currency),
                            color: Colors.orange,
                          ),
                          const Text(
                            '=',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                          _StatChip(
                            label: 'Net',
                            value: CurrencyHelper.format(totalNet, currency),
                            color: Colors.green,
                            large: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Per-Event Payouts ────────────────────────────────
              Text(
                'Per Event',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (events.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'No events yet. Create your first event!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...events.map((event) {
                  final gross = event.grossRevenue.toDouble();
                  final fee = _platformFee(gross);
                  final net = _netPayout(gross);
                  final isPending = _pendingPayouts.contains(event.id);
                  final isProcessed = _processedPayouts.contains(event.id);
                  final canRequest = gross > 0 && !isPending && !isProcessed;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _statusChip(isPending, isProcessed, gross),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat('MMM d, y').format(event.startAt)} • ${event.totalSold} tickets sold',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Revenue breakdown
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                _summaryRow(
                                  'Gross Revenue',
                                  CurrencyHelper.format(gross, currency),
                                ),
                                _summaryRow(
                                  'Platform Fee (5%)',
                                  '- ${CurrencyHelper.format(fee, currency)}',
                                ),
                                const Divider(height: 12),
                                _summaryRow(
                                  'Net Payout',
                                  CurrencyHelper.format(net, currency),
                                  bold: true,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Action
                          if (gross == 0)
                            const Text(
                              'No revenue yet.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            )
                          else if (isProcessed)
                            const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Payout processed',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                icon: isPending
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.account_balance,
                                        size: 16,
                                      ),
                                label: Text(
                                  isPending
                                      ? 'Processing...'
                                      : 'Request Payout',
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: canRequest
                                      ? Colors.green
                                      : Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                                onPressed: canRequest
                                    ? () => _requestPayout(event)
                                    : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _statusChip(bool isPending, bool isProcessed, double gross) {
    if (gross == 0) {
      return const SizedBox.shrink();
    }
    if (isProcessed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'PAID',
          style: TextStyle(
            color: Colors.green,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'PENDING',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'AVAILABLE',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool large;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: large ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
