import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eventhub/providers/auth_provider.dart';
import 'package:eventhub/models/app_user.dart';
import 'package:eventhub/features/auth/login_screen.dart';
import 'package:eventhub/features/attendee/browse/browse_screen.dart';
import 'package:eventhub/features/attendee/event_detail/event_detail_screen.dart';
import 'package:eventhub/features/attendee/checkout/checkout_screen.dart';
import 'package:eventhub/features/attendee/my_tickets/my_tickets_screen.dart';
import 'package:eventhub/features/attendee/ticket_qr/ticket_qr_screen.dart';
import 'package:eventhub/models/booking.dart';
import 'package:eventhub/features/organizer/dashboard/organizer_dashboard_screen.dart';
import 'package:eventhub/features/organizer/create_event/create_event_screen.dart';
import 'package:eventhub/features/organizer/ticket_tiers/ticket_tiers_screen.dart';
import 'package:eventhub/features/admin/dashboard/admin_dashboard_screen.dart';

part 'app_router.g.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

@riverpod
GoRouter router(Ref ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      
      // Still loading
      if (authState.isLoading) return null;

      final user = authState.asData?.value;
      final isAuth = user != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuth) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn || state.matchedLocation == '/') {
        final role = user.role;
        switch (role) {
          case UserRole.attendee:
            return '/attendee/browse';
          case UserRole.organizer:
            return '/organizer/dashboard';
          case UserRole.admin:
            return '/admin/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/attendee/browse',
        builder: (context, state) => const BrowseScreen(),
      ),
      GoRoute(
        path: '/attendee/event/:id',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/attendee/event/:id/checkout',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return CheckoutScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/attendee/my_tickets',
        builder: (context, state) => const MyTicketsScreen(),
      ),
      GoRoute(
        path: '/attendee/ticket_qr',
        builder: (context, state) {
          final booking = state.extra as Booking;
          return TicketQrScreen(booking: booking);
        },
      ),
      GoRoute(
        path: '/organizer/dashboard',
        builder: (context, state) => const OrganizerDashboardScreen(),
      ),
      GoRoute(
        path: '/organizer/create_event',
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: '/organizer/event/:id/tickets',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return TicketTiersScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}
