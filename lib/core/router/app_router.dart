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
import 'package:eventhub/features/organizer/analytics/analytics_screen.dart';
import 'package:eventhub/features/organizer/promo_manager/promo_manager_screen.dart';
import 'package:eventhub/features/admin/dashboard/admin_dashboard_screen.dart';

import 'package:eventhub/features/organizer/attendees/attendees_screen.dart';

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
      if (authState.isLoading) return null;

      final user = authState.asData?.value;
      final isAuth = user != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuth) return isLoggingIn ? null : '/login';

      if (isLoggingIn || state.matchedLocation == '/') {
        switch (user.role) {
          case UserRole.attendee: return '/attendee/browse';
          case UserRole.organizer: return '/organizer/dashboard';
          case UserRole.admin: return '/admin/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Center(child: CircularProgressIndicator()))),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),

      // ── Attendee ───────────────────────────────────────────────
      GoRoute(path: '/attendee/browse', builder: (_, _) => const BrowseScreen()),
      GoRoute(path: '/attendee/my_tickets', builder: (_, _) => const MyTicketsScreen()),
      GoRoute(path: '/attendee/ticket_qr', builder: (_, state) => TicketQrScreen(booking: state.extra as Booking)),
      GoRoute(path: '/attendee/event/:id', builder: (_, state) => EventDetailScreen(eventId: state.pathParameters['id']!)),
      GoRoute(path: '/attendee/event/:id/checkout', builder: (_, state) => CheckoutScreen(eventId: state.pathParameters['id']!)),

      // ── Organizer ──────────────────────────────────────────────
      GoRoute(path: '/organizer/dashboard', builder: (_, _) => const OrganizerDashboardScreen()),
      GoRoute(path: '/organizer/create_event', builder: (_, _) => const CreateEventScreen()),
      GoRoute(path: '/organizer/event/:id/tickets', builder: (_, state) => TicketTiersScreen(eventId: state.pathParameters['id']!)),
      GoRoute(path: '/organizer/event/:id/analytics', builder: (_, state) => AnalyticsScreen(eventId: state.pathParameters['id']!)),
      GoRoute(path: '/organizer/event/:id/promo', builder: (_, state) => PromoManagerScreen(eventId: state.pathParameters['id']!)),
      GoRoute(path: '/organizer/event/:id/attendees', builder: (_, state) => AttendeesScreen(eventId: state.pathParameters['id']!)),

      // ── Admin ──────────────────────────────────────────────────
      GoRoute(path: '/admin/dashboard', builder: (_, _) => const AdminDashboardScreen()),
    ],
  );
}
