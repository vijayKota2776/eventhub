import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/repositories/event_repository.dart';
import 'package:eventhub/models/event.dart';
import 'package:eventhub/features/organizer/scanner/scanner_screen.dart';

class OrganizerDashboardScreen extends ConsumerStatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  ConsumerState<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends ConsumerState<OrganizerDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authControllerProvider).value;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          )
        ],
      ),
      body: _currentIndex == 0 ? FutureBuilder<List<Event>>(
        future: ref.read(eventRepositoryProvider).getEventsByOrganizer(user!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No events created yet.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.push('/organizer/create_event'),
                    child: const Text('Create New Event'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event.title),
                subtitle: Text(event.status),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.analytics, color: Colors.blue),
                      tooltip: 'Analytics',
                      onPressed: () => context.push('/organizer/event/${event.id}/analytics'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.people, color: Colors.orange),
                      tooltip: 'Attendees & CSV',
                      onPressed: () => context.push('/organizer/event/${event.id}/attendees'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.local_offer, color: Colors.purple),
                      tooltip: 'Promo Codes & Refunds',
                      onPressed: () => context.push('/organizer/event/${event.id}/promo'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.confirmation_num, color: Colors.green),
                      tooltip: 'Tickets',
                      onPressed: () => context.push('/organizer/event/${event.id}/tickets'),
                    ),
                  ],
                ),
                onTap: () {
                  context.push('/organizer/event/${event.id}/tickets');
                },
              );
            },
          );
        },
      ) : _currentIndex == 1 ? const ScannerScreen() : const SizedBox(),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () => context.push('/organizer/create_event'),
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
        ],
      ),
    );
  }
}
