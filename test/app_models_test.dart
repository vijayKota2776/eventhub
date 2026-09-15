import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/models/event_review.dart';
import 'package:eventhub/models/app_user.dart';

void main() {
  group('EventHub Models Test', () {
    test('EventReview fromJson and toJson serialization', () {
      final json = {
        'id': 'rev-123',
        'event_id': 'evt-456',
        'user_id': 'usr-789',
        'user_name': 'John Doe',
        'rating': 5,
        'comment': 'Phenomenal conference with great speakers!',
        'created_at': '2026-09-15T00:00:00.000Z',
      };

      final review = EventReview.fromJson(json);
      expect(review.id, 'rev-123');
      expect(review.rating, 5);
      expect(review.userName, 'John Doe');
      expect(review.comment, contains('Phenomenal'));

      final serialized = review.toJson();
      expect(serialized['rating'], 5);
      expect(serialized['user_id'], 'usr-789');
    });

    test('AppUser UserRole enum and parsing', () {
      final user = AppUser(
        id: 'usr-1',
        email: 'admin@eventhub.io',
        name: 'Admin User',
        role: UserRole.admin,
      );

      expect(user.role, UserRole.admin);
      expect(user.email, 'admin@eventhub.io');
    });
  });
}
