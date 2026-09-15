import 'package:flutter/material.dart';
import 'package:eventhub/models/booking.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketQrScreen extends StatelessWidget {
  final Booking booking;
  const TicketQrScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // Generate QR payload
    // Format: EVT:{event_id}|BK:{booking_id}|T:{qr_token}
    final qrData = 'EVT:${booking.eventId}|BK:${booking.id}|T:${booking.qrToken ?? "no_token"}';

    return Scaffold(
      appBar: AppBar(title: const Text('Your Ticket')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Show this QR code at the venue',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 250.0,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Booking ID: ${booking.id}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
