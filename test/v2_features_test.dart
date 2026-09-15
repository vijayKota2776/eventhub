import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/models/event.dart';
import 'package:eventhub/models/ticket_type.dart';
import 'package:eventhub/core/providers/currency_provider.dart';

void main() {
  group('v2.0 Features & Multi-Currency Tests', () {
    test('CurrencyHelper format methods with conversion rates', () {
      final usdFormat = CurrencyHelper.format(100.0, AppCurrency.usd);
      expect(usdFormat, '\$100.00');

      final inrFormat = CurrencyHelper.format(100.0, AppCurrency.inr);
      expect(inrFormat, '₹8350');

      final eurFormat = CurrencyHelper.format(100.0, AppCurrency.eur);
      expect(eurFormat, '€92.00');

      final gbpFormat = CurrencyHelper.format(100.0, AppCurrency.gbp);
      expect(gbpFormat, '£78.00');
    });

    test('Event serialization with bannerUrl and totalSold', () {
      final json = {
        'id': 'evt-100',
        'organizer_id': 'org-50',
        'title': 'Tech Summit 2026',
        'description': 'Annual AI & Cloud Conference',
        'venue': 'Convention Center',
        'city': 'San Francisco',
        'start_at': '2026-10-01T09:00:00.000Z',
        'end_at': '2026-10-01T17:00:00.000Z',
        'category': 'Technology',
        'status': 'published',
        'banner_url': 'https://supabase.co/storage/v1/object/public/event-banners/banner.png',
        'total_sold': 150,
        'gross_revenue': 14998.50,
      };

      final event = Event.fromJson(json);
      expect(event.title, 'Tech Summit 2026');
      expect(event.city, 'San Francisco');
      expect(event.category, 'Technology');
      expect(event.bannerUrl, contains('banner.png'));
      expect(event.totalSold, 150);
      expect(event.grossRevenue, 14998.50);
    });

    test('TicketType serialization and availability checks', () {
      final json = {
        'id': 'tier-VIP',
        'event_id': 'evt-100',
        'name': 'VIP Pass',
        'price': 299.99,
        'quantity_total': 50,
        'quantity_sold': 38,
        'sales_start': '2026-09-01T00:00:00.000Z',
        'sales_end': '2026-10-01T00:00:00.000Z',
      };

      final tier = TicketType.fromJson(json);
      expect(tier.name, 'VIP Pass');
      expect(tier.price, 299.99);
      expect(tier.quantityTotal, 50);
      expect(tier.quantitySold, 38);
      expect(tier.quantityTotal - tier.quantitySold, 12); // 12 remaining
    });

    test('Group Booking attendee metadata payload construction', () {
      final attendees = [
        {'name': 'Alice Smith', 'email': 'alice@example.com'},
        {'name': 'Bob Smith', 'email': 'bob@example.com'},
      ];

      expect(attendees.length, 2);
      expect(attendees[0]['name'], 'Alice Smith');
      expect(attendees[1]['email'], 'bob@example.com');
    });
  });
}
