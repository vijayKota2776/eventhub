import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eventhub/models/event.dart';
import 'package:intl/intl.dart';

class CalendarUtils {
  static String generateGoogleCalendarUrl(Event event) {
    final format = DateFormat("yyyyMMdd'T'HHmmss'Z'");
    final startStr = format.format(event.startAt.toUtc());
    final endStr = format.format(event.endAt.toUtc());
    final title = Uri.encodeComponent(event.title);
    final details = Uri.encodeComponent(event.description ?? 'Event booked via EventHub');
    final location = Uri.encodeComponent('${event.venue}, ${event.city}');

    return 'https://calendar.google.com/calendar/render?action=TEMPLATE&text=$title&dates=$startStr/$endStr&details=$details&location=$location';
  }

  static String getShareInvitation(Event event) {
    final dateFormat = DateFormat('EEEE, MMM d, y • h:mm a');
    final formattedDate = dateFormat.format(event.startAt);

    return '''
🎉 You're invited to ${event.title}!

📅 When: $formattedDate
📍 Where: ${event.venue}, ${event.city}
🏷️ Category: ${event.category}

${event.description != null && event.description!.isNotEmpty ? '${event.description}\n' : ''}
Book your tickets exclusively on EventHub!
''';
  }

  static void copyShareInvitation(BuildContext context, Event event) {
    final text = getShareInvitation(event);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Event invitation copied to clipboard! Share it with friends.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Build a generic Google Calendar URL from raw params (booking-level, no full Event model needed)
  static String googleCalendarUrl({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String description = '',
    String location = '',
  }) {
    final fmt = DateFormat("yyyyMMdd'T'HHmmss'Z'");
    final start = fmt.format(startTime.toUtc());
    final end = fmt.format(endTime.toUtc());
    return 'https://calendar.google.com/calendar/render?action=TEMPLATE'
        '&text=${Uri.encodeComponent(title)}'
        '&dates=$start/$end'
        '&details=${Uri.encodeComponent(description)}'
        '&location=${Uri.encodeComponent(location)}';
  }

  /// Build a shareable invite text for a booking (no full Event model needed)
  static String shareableInviteText({
    required String eventTitle,
    required DateTime startTime,
    required String location,
    required String bookingId,
  }) {
    final fmt = DateFormat('EEEE, MMM d, y • h:mm a');
    return '''
🎉 I'm attending $eventTitle!

📅 When: ${fmt.format(startTime)}
📍 Where: $location
🎟️ Booking ID: ${bookingId.substring(0, 8)}

Booked via EventHub!''';
  }
}
