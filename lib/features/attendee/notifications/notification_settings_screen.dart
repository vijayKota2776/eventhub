import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Preferences stored locally in UI state
  // (persisted via SharedPreferences in a real app)
  final Map<String, bool> _prefs = {
    'booking_confirmed': true,
    'event_reminder_24h': true,
    'event_reminder_1h': true,
    'waitlist_available': true,
    'refund_update': true,
    'new_events_city': false,
    'promotional': false,
    'organizer_updates': false,
  };

  static const _sections = [
    {
      'title': 'Booking & Tickets',
      'icon': Icons.confirmation_number_outlined,
      'color': Colors.blue,
      'items': [
        {
          'key': 'booking_confirmed',
          'label': 'Booking Confirmed',
          'sub': 'When your ticket purchase is successful',
        },
        {
          'key': 'refund_update',
          'label': 'Refund Status',
          'sub': 'When organizer approves or rejects your refund',
        },
      ],
    },
    {
      'title': 'Event Reminders',
      'icon': Icons.alarm,
      'color': Colors.orange,
      'items': [
        {
          'key': 'event_reminder_24h',
          'label': '24 Hours Before',
          'sub': 'Reminder the day before your event',
        },
        {
          'key': 'event_reminder_1h',
          'label': '1 Hour Before',
          'sub': 'Last-minute reminder before entry opens',
        },
      ],
    },
    {
      'title': 'Discovery',
      'icon': Icons.explore_outlined,
      'color': Colors.purple,
      'items': [
        {
          'key': 'waitlist_available',
          'label': 'Waitlist Spot Available',
          'sub': 'When a ticket opens up for a waitlisted event',
        },
        {
          'key': 'new_events_city',
          'label': 'New Events in Your City',
          'sub': 'Weekly digest of new events nearby',
        },
      ],
    },
    {
      'title': 'Promotions',
      'icon': Icons.local_offer_outlined,
      'color': Colors.green,
      'items': [
        {
          'key': 'promotional',
          'label': 'Promotions & Deals',
          'sub': 'Promo codes, flash sales, and special offers',
        },
        {
          'key': 'organizer_updates',
          'label': 'Organizer Announcements',
          'sub': 'Updates from organizers of events you booked',
        },
      ],
    },
  ];

  int get _enabledCount => _prefs.values.where((v) => v).length;

  void _toggleAll(bool value) {
    setState(() {
      for (final key in _prefs.keys) {
        _prefs[key] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allEnabled = _prefs.values.every((v) => v);
    final noneEnabled = _prefs.values.every((v) => !v);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          TextButton(
            onPressed: () {
              _toggleAll(!allEnabled);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    allEnabled
                        ? '🔕 All notifications off'
                        : '🔔 All notifications on',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(allEnabled ? 'Disable All' : 'Enable All'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Summary Banner ─────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: noneEnabled
                  ? Colors.grey.withValues(alpha: 0.1)
                  : colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: noneEnabled
                    ? Colors.grey.withValues(alpha: 0.3)
                    : colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  noneEnabled
                      ? Icons.notifications_off_outlined
                      : Icons.notifications_active_outlined,
                  size: 36,
                  color: noneEnabled ? Colors.grey : colorScheme.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        noneEnabled
                            ? 'All Notifications Off'
                            : '$_enabledCount of ${_prefs.length} enabled',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: noneEnabled
                              ? Colors.grey
                              : colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        noneEnabled
                            ? 'You won\'t receive any alerts from EventHub.'
                            : 'You\'ll receive timely updates for important events.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Notification Sections ──────────────────────────────
          ..._sections.map((section) {
            final items = section['items']! as List;
            final icon = section['icon']! as IconData;
            final color = section['color']! as Color;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: color),
                      const SizedBox(width: 8),
                      Text(
                        section['title']! as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value as Map<String, String>;
                      final key = item['key']!;
                      final isEnabled = _prefs[key] ?? false;
                      final isLast = idx == items.length - 1;

                      return Column(
                        children: [
                          SwitchListTile(
                            value: isEnabled,
                            onChanged: (val) =>
                                setState(() => _prefs[key] = val),
                            title: Text(
                              item['label']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              item['sub']!,
                              style: const TextStyle(fontSize: 12),
                            ),
                            activeThumbColor: color,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                          ),
                          if (!isLast)
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }),

          // ── Save note ─────────────────────────────────────────
          Center(
            child: Text(
              'Preferences are saved automatically.',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Save Button ────────────────────────────────────────
          FilledButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Preferences'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Notification preferences saved!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
