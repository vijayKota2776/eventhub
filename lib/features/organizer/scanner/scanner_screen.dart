import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/repositories/booking_repository.dart';
import 'package:eventhub/repositories/event_repository.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  bool _isTorchOn = false;

  // Offline cache
  final Set<String> _cachedBookingIds = {};
  final Set<String> _alreadyScannedIds = {};
  final List<String> _offlinePendingSync = [];
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _precacheOrganizerBookings();
  }

  Future<void> _precacheOrganizerBookings() async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    try {
      final events = await ref.read(eventRepositoryProvider).getEventsByOrganizer(user.id);
      for (final ev in events) {
        final attendees = await ref.read(eventRepositoryProvider).getEventAttendees(ev.id);
        for (final a in attendees) {
          if (a['id'] != null) {
            _cachedBookingIds.add(a['id'].toString());
            if (a['status'] == 'attended') {
              _alreadyScannedIds.add(a['id'].toString());
            }
          }
        }
      }
      if (mounted) setState(() {});
    } catch (_) {
      // Ignore offline load errors
    }
  }

  Future<void> _syncOfflineQueue() async {
    if (_offlinePendingSync.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No offline scans pending sync.')),
      );
      return;
    }

    setState(() => _isSyncing = true);
    final user = ref.read(authControllerProvider).value!;
    int success = 0;

    final toSync = List<String>.from(_offlinePendingSync);
    for (final bId in toSync) {
      try {
        await ref.read(bookingRepositoryProvider).checkInTicket(bId, user.id);
        _offlinePendingSync.remove(bId);
        success++;
      } catch (_) {
        // Stop syncing if network remains down
        break;
      }
    }

    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Synced $success check-ins to server! Remaining: ${_offlinePendingSync.length}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleScan(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null) return;

    // Expected format: EVT:{event_id}|BK:{booking_id}|T:{qr_token}
    if (!code.contains('BK:')) return;

    setState(() => _isProcessing = true);

    try {
      // Parse booking ID
      final parts = code.split('|');
      String? bookingId;
      for (final part in parts) {
        if (part.startsWith('BK:')) {
          bookingId = part.substring(3);
          break;
        }
      }

      if (bookingId == null) throw Exception("Invalid QR format");

      if (_alreadyScannedIds.contains(bookingId)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ Ticket ALREADY Used!'), backgroundColor: Colors.orange),
          );
        }
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      final user = ref.read(authControllerProvider).value!;

      try {
        // 1. Try online check-in first
        final status = await ref.read(bookingRepositoryProvider).checkInTicket(bookingId, user.id);
        if (mounted) {
          if (status == 'OK') {
            _alreadyScannedIds.add(bookingId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Check-in Verified (Online)!'), backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ Ticket Error: $status'), backgroundColor: Colors.red),
            );
          }
        }
      } catch (networkError) {
        // 2. Offline fallback if offline cache has the booking ID
        if (_cachedBookingIds.contains(bookingId)) {
          _alreadyScannedIds.add(bookingId);
          _offlinePendingSync.add(bookingId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚡ Verified (Offline Mode — Saved to sync queue)'),
                backgroundColor: Colors.teal,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('❌ Ticket not found in local cache'), backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing scan: $e'), backgroundColor: Colors.red),
        );
      }
    }

    // Wait a couple seconds before allowing the next scan
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Tickets'),
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: 'Toggle Flash',
            onPressed: () {
              _scannerController.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.cloud_sync,
              color: _offlinePendingSync.isNotEmpty ? Colors.amber : Colors.white,
            ),
            tooltip: 'Sync Offline Queue (${_offlinePendingSync.length})',
            onPressed: _isSyncing ? null : _syncOfflineQueue,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleScan,
          ),
          
          // Scanner Overlay Frame
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Top Info Banner: Cached count & offline queue
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sd_storage, color: Colors.greenAccent, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Cache: ${_cachedBookingIds.length} tickets',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  if (_offlinePendingSync.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.sync_problem, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${_offlinePendingSync.length} queued',
                          style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.greenAccent),
                    SizedBox(height: 16),
                    Text(
                      'Verifying Ticket QR...',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
