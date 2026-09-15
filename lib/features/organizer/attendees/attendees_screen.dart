import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub/repositories/event_repository.dart';

class AttendeesScreen extends ConsumerStatefulWidget {
  final String eventId;
  const AttendeesScreen({super.key, required this.eventId});

  @override
  ConsumerState<AttendeesScreen> createState() => _AttendeesScreenState();
}

class _AttendeesScreenState extends ConsumerState<AttendeesScreen> {
  late Future<List<Map<String, dynamic>>> _attendeesFuture;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAttendees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAttendees() {
    _attendeesFuture = ref.read(eventRepositoryProvider).getEventAttendees(widget.eventId);
  }

  void _exportCsv(List<Map<String, dynamic>> attendees) {
    final buffer = StringBuffer();
    buffer.writeln('Booking ID,Attendee Name,Email,Ticket Tier,Quantity,Amount Paid,Status,Date');

    for (final a in attendees) {
      final id = a['id'] ?? '';
      final name = (a['users']?['name'] ?? 'Attendee').toString().replaceAll(',', ' ');
      final email = (a['users']?['email'] ?? '').toString();
      final tier = (a['ticket_types']?['name'] ?? 'General').toString().replaceAll(',', ' ');
      final qty = a['quantity'] ?? 1;
      final amount = a['total_amount'] ?? 0;
      final status = a['status'] ?? 'confirmed';
      final date = a['created_at'] != null ? a['created_at'].toString().substring(0, 10) : '';

      buffer.writeln('$id,$name,$email,$tier,$qty,$amount,$status,$date');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 CSV exported and copied to clipboard! Paste into Excel or Sheets.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendee Roster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export CSV',
            onPressed: () async {
              final list = await _attendeesFuture;
              if (mounted) _exportCsv(list);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _attendeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading attendees: ${snapshot.error}'));
          }

          var attendees = snapshot.data ?? [];
          final totalCount = attendees.length;
          final attendedCount = attendees.where((a) => a['status'] == 'attended').length;
          final totalRevenue = attendees.fold<double>(
            0.0, 
            (sum, a) => sum + ((a['total_amount'] as num?)?.toDouble() ?? 0.0),
          );

          if (_searchQuery.isNotEmpty) {
            attendees = attendees.where((a) {
              final name = (a['users']?['name'] ?? '').toString().toLowerCase();
              final email = (a['users']?['email'] ?? '').toString().toLowerCase();
              return name.contains(_searchQuery) || email.contains(_searchQuery);
            }).toList();
          }

          return Column(
            children: [
              // Summary Banner
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Total Attendees', '$totalCount'),
                    _buildStatCol('Checked In', '$attendedCount'),
                    _buildStatCol('Revenue', '\$${totalRevenue.toStringAsFixed(0)}'),
                  ],
                ),
              ),

              // Search Bar & Export Action
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search attendee name or email...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (val) {
                          setState(() => _searchQuery = val.toLowerCase().trim());
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('CSV'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onPressed: () => _exportCsv(snapshot.data ?? []),
                    ),
                  ],
                ),
              ),

              // Attendee List
              Expanded(
                child: attendees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No attendees found.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            _loadAttendees();
                          });
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: attendees.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final a = attendees[index];
                            final name = (a['users']?['name'] ?? 'Attendee').toString();
                            final email = (a['users']?['email'] ?? '').toString();
                            final tier = (a['ticket_types']?['name'] ?? 'General').toString();
                            final qty = a['quantity'] ?? 1;
                            final amount = (a['total_amount'] as num?)?.toDouble() ?? 0.0;
                            final status = (a['status'] ?? 'confirmed').toString();
                            final isAttended = status == 'attended';

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isAttended ? Colors.green.shade100 : Colors.blue.shade100,
                                child: Icon(
                                  isAttended ? Icons.check : Icons.person,
                                  color: isAttended ? Colors.green : Colors.blue,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isAttended 
                                          ? Colors.green.withValues(alpha: 0.15) 
                                          : Colors.blue.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isAttended ? 'CHECKED IN' : status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isAttended ? Colors.green : Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(email, style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tier: $tier • Qty: $qty • Total: \$${amount.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
