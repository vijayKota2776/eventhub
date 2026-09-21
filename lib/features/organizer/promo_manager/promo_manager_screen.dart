import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub/repositories/event_repository.dart';
import 'package:eventhub/repositories/booking_repository.dart';

// Refund request model (minimal, inline)
class RefundRequest {
  final String id;
  final String bookingId;
  final double amount;
  final String reason;
  final String status;
  final DateTime createdAt;
  RefundRequest({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.reason,
    required this.status,
    required this.createdAt,
  });
  factory RefundRequest.fromJson(Map<String, dynamic> j) => RefundRequest(
    id: j['id'],
    bookingId: j['booking_id'],
    amount: double.parse(j['amount'].toString()),
    reason: j['reason'] ?? '',
    status: j['status'],
    createdAt: DateTime.parse(j['created_at']),
  );
}

class PromoManagerScreen extends ConsumerStatefulWidget {
  final String eventId;
  const PromoManagerScreen({super.key, required this.eventId});

  @override
  ConsumerState<PromoManagerScreen> createState() => _PromoManagerScreenState();
}

class _PromoManagerScreenState extends ConsumerState<PromoManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.local_offer), text: 'Promo Codes'),
            Tab(icon: Icon(Icons.money_off), text: 'Refunds'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _PromoCodesTab(eventId: widget.eventId),
          _RefundsTab(eventId: widget.eventId),
        ],
      ),
    );
  }
}

// ── PROMO CODES TAB ────────────────────────────────────────────────
class _PromoCodesTab extends ConsumerStatefulWidget {
  final String eventId;
  const _PromoCodesTab({required this.eventId});

  @override
  ConsumerState<_PromoCodesTab> createState() => _PromoCodesTabState();
}

class _PromoCodesTabState extends ConsumerState<_PromoCodesTab> {
  bool _loading = false;
  List<Map<String, dynamic>> _codes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ref
          .read(eventRepositoryProvider)
          .getPromoCodes(widget.eventId);
      if (mounted) setState(() => _codes = res);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showCreateDialog() async {
    final codeCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final pctCtrl = TextEditingController();
    final maxCtrl = TextEditingController();
    bool isPct = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Create Promo Code'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    hintText: 'e.g. EARLYBIRD20',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Type: '),
                    ChoiceChip(
                      label: const Text('Flat \$'),
                      selected: !isPct,
                      onSelected: (_) => setS(() => isPct = false),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Percent %'),
                      selected: isPct,
                      onSelected: (_) => setS(() => isPct = true),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: isPct ? pctCtrl : amtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isPct ? 'Discount %' : 'Discount \$',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: maxCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max Uses (leave empty = unlimited)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (codeCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                await ref
                    .read(eventRepositoryProvider)
                    .createPromoCode(
                      eventId: widget.eventId,
                      code: codeCtrl.text.trim().toUpperCase(),
                      discountAmount: !isPct && amtCtrl.text.isNotEmpty
                          ? double.tryParse(amtCtrl.text)
                          : null,
                      discountPercent: isPct && pctCtrl.text.isNotEmpty
                          ? double.tryParse(pctCtrl.text)
                          : null,
                      maxUses: maxCtrl.text.isNotEmpty
                          ? int.tryParse(maxCtrl.text)
                          : null,
                    );
                _load();
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _codes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_offer, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No promo codes yet'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _codes.length,
              itemBuilder: (_, i) {
                final c = _codes[i];
                final discount = c['discount_percent'] != null
                    ? '${c['discount_percent']}% off'
                    : '\$${c['discount_amount']} off';
                final usage = '${c['uses']}/${c['max_uses'] ?? '∞'} uses';
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_offer,
                      color: Colors.purple,
                    ),
                    title: Text(
                      c['code'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    subtitle: Text('$discount  •  $usage'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Code'),
      ),
    );
  }
}

// ── REFUNDS TAB ────────────────────────────────────────────────────
class _RefundsTab extends ConsumerStatefulWidget {
  final String eventId;
  const _RefundsTab({required this.eventId});

  @override
  ConsumerState<_RefundsTab> createState() => _RefundsTabState();
}

class _RefundsTabState extends ConsumerState<_RefundsTab> {
  bool _loading = false;
  List<RefundRequest> _refunds = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ref
          .read(bookingRepositoryProvider)
          .getRefundRequestsForEvent(widget.eventId);
      if (mounted)
        setState(() => _refunds = res.map(RefundRequest.fromJson).toList());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _update(String refundId, String status) async {
    await ref
        .read(bookingRepositoryProvider)
        .updateRefundStatus(refundId, status);
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Refund $status')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_refunds.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('No pending refund requests'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _refunds.length,
      itemBuilder: (_, i) {
        final r = _refunds[i];
        Color statusColor = r.status == 'pending'
            ? Colors.orange
            : r.status == 'approved'
            ? Colors.green
            : Colors.red;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking #${r.bookingId.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                        r.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Amount: \$${r.amount.toStringAsFixed(2)}'),
                Text(
                  'Reason: ${r.reason}',
                  style: const TextStyle(color: Colors.grey),
                ),
                if (r.status == 'pending') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _update(r.id, 'rejected'),
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text(
                            'Reject',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _update(r.id, 'approved'),
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
