import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/core/providers/currency_provider.dart';
import 'package:eventhub/models/ticket_type.dart';
import 'package:eventhub/repositories/event_repository.dart';

class SeatSelectionScreen extends ConsumerStatefulWidget {
  final String eventId;
  const SeatSelectionScreen({super.key, required this.eventId});

  @override
  ConsumerState<SeatSelectionScreen> createState() =>
      _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends ConsumerState<SeatSelectionScreen> {
  final Set<String> _selectedSeats = {};
  // Mock occupied seats in the venue
  final Set<String> _occupiedSeats = {
    'A2',
    'A6',
    'B4',
    'C1',
    'C7',
    'D4',
    'D5',
    'F2',
    'F7',
  };

  final List<String> _rows = ['A', 'B', 'C', 'D', 'E', 'F'];
  final int _seatsPerRow = 8;

  double _getPriceForSeat(String seatId, List<TicketType> tiers) {
    final row = seatId[0];
    if (tiers.isNotEmpty) {
      if (row == 'A' || row == 'B') {
        // Highest tier or first tier
        return tiers.last.price;
      } else if (row == 'C' || row == 'D') {
        return tiers.length > 1
            ? tiers[tiers.length ~/ 2].price
            : tiers.first.price;
      } else {
        return tiers.first.price;
      }
    }
    // Fallback prices if no custom tiers
    if (row == 'A' || row == 'B') return 75.0;
    if (row == 'C' || row == 'D') return 50.0;
    return 30.0;
  }

  double _calculateTotal(List<TicketType> tiers) {
    double total = 0;
    for (final seat in _selectedSeats) {
      total += _getPriceForSeat(seat, tiers);
    }
    return total;
  }

  void _toggleSeat(String seatId) {
    if (_occupiedSeats.contains(seatId)) return;

    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
      } else {
        _selectedSeats.add(seatId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Seats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Seating Guide',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Venue Seating Guide'),
                  content: const Text(
                    '• Rows A-B: VIP Zone (Front View)\n'
                    '• Rows C-D: Premium Zone (Center View)\n'
                    '• Rows E-F: General Admission\n\n'
                    'Tap any available seat to select.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<TicketType>>(
        future: ref
            .read(eventRepositoryProvider)
            .getTicketTypes(widget.eventId),
        builder: (context, snapshot) {
          final tiers = snapshot.data ?? [];
          final totalPrice = _calculateTotal(tiers);

          return Column(
            children: [
              // Screen / Stage Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                  border: Border.all(color: Colors.blue.shade300, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '🎬 STAGE / MAIN SCREEN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),

              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(
                      'Available',
                      Colors.grey.shade300,
                      isBorder: true,
                    ),
                    _buildLegendItem('Selected', Colors.blue, isBorder: false),
                    _buildLegendItem(
                      'Occupied',
                      Colors.grey.shade600,
                      isBorder: false,
                    ),
                  ],
                ),
              ),

              const Divider(height: 24),

              // Seating Grid
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: _rows.map((row) {
                      String zoneName = 'General';
                      Color zoneColor = Colors.grey.shade700;
                      if (row == 'A' || row == 'B') {
                        zoneName = 'VIP';
                        zoneColor = Colors.amber.shade800;
                      } else if (row == 'C' || row == 'D') {
                        zoneName = 'Premium';
                        zoneColor = Colors.purple;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Row Letter
                            SizedBox(
                              width: 24,
                              child: Text(
                                row,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: zoneColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Seats
                            ...List.generate(_seatsPerRow, (index) {
                              final seatNumber = index + 1;
                              final seatId = '$row$seatNumber';
                              final isOccupied = _occupiedSeats.contains(
                                seatId,
                              );
                              final isSelected = _selectedSeats.contains(
                                seatId,
                              );

                              // Add an aisle gap in the middle
                              final isAisle = index == 3;

                              return Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _toggleSeat(seatId),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isOccupied
                                            ? Colors.grey.shade400
                                            : isSelected
                                            ? Colors.blue
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue.shade700
                                              : isOccupied
                                              ? Colors.grey.shade500
                                              : Colors.grey.shade400,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$seatNumber',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isOccupied
                                                ? Colors.grey.shade600
                                                : isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isAisle) const SizedBox(width: 16),
                                ],
                              );
                            }),

                            const SizedBox(width: 8),
                            // Zone Label
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: zoneColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                zoneName,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: zoneColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Selected Seats Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedSeats.isEmpty
                                    ? 'No seats selected'
                                    : 'Selected (${_selectedSeats.length}): ${_selectedSeats.join(', ')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Total: ${CurrencyHelper.format(totalPrice, currency)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Checkout'),
                            onPressed: _selectedSeats.isNotEmpty
                                ? () {
                                    context.push(
                                      '/attendee/event/${widget.eventId}/checkout',
                                      extra: {
                                        'selectedSeats': _selectedSeats
                                            .toList(),
                                      },
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {required bool isBorder}) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isBorder ? Colors.white : color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
