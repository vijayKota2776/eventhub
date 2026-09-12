import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/repositories/booking_repository.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

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

      final user = ref.read(authControllerProvider).value!;
      
      final status = await ref.read(bookingRepositoryProvider).checkInTicket(
        bookingId, 
        user.id,
      );

      if (mounted) {
        if (status == 'OK') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Check-in Successful!'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Ticket Error: $status'), backgroundColor: Colors.red),
          );
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
    await Future.delayed(const Duration(seconds: 3));
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
      appBar: AppBar(title: const Text('Scan Tickets')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleScan,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processing...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
