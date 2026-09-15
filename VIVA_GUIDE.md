# EventHub — Project Viva Documentation

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Problem Statement](#2-problem-statement)
3. [Tech Stack — Explained](#3-tech-stack--explained)
4. [Architecture Deep Dive](#4-architecture-deep-dive)
5. [Database Design](#5-database-design)
6. [Key Features & How They Work](#6-key-features--how-they-work)
7. [State Management — Riverpod](#7-state-management--riverpod)
8. [Security](#8-security)
9. [What is Implemented (v1.0 + v1.1)](#9-what-is-implemented-v10--v11)
10. [What is Left (Roadmap)](#10-what-is-left-roadmap)
11. [Common Viva Questions & Answers](#11-common-viva-questions--answers)

---

## 1. Project Overview

**EventHub** is a full-stack, cross-platform mobile application built with **Flutter** for the frontend and **Supabase** as the backend. It allows:

- **Organizers** to create and publish events with multiple ticket pricing tiers.
- **Attendees** to browse events, book tickets (with inventory guarantees), and get a QR-code digital ticket.
- **Staff** to scan QR codes on-site for attendee check-in.
- **Admins** to oversee the platform — approve events and view platform-wide metrics.

It is a real, production-grade architecture covering auth, payments, real-time updates, analytics, and offline capability.

---

## 2. Problem Statement

Traditional event ticketing platforms (BookMyShow, Eventbrite) are:
- **Expensive** for small organizers (high commission).
- **Complex** to set up and manage.
- **Not mobile-first** for smaller, local events.

EventHub solves this by providing a self-hosted, open-source platform where organizers have full control, zero commission, and a simple mobile-first experience.

---

## 3. Tech Stack — Explained

### Flutter (Frontend)
Flutter is Google's UI toolkit for building natively compiled apps for mobile, web, and desktop from a **single codebase**. We use Flutter because:
- **Hot reload** speeds up development significantly.
- **Widgets** are composable building blocks — everything is a widget.
- **Dart** language is strongly typed, reducing runtime bugs.
- It compiles to native ARM machine code (not JavaScript), giving near-native performance.

### Supabase (Backend)
Supabase is an open-source Firebase alternative built on **PostgreSQL**. It provides:
| Service | What we use it for |
|---|---|
| **Auth** | Email/password login, JWT session tokens, role-based access |
| **PostgreSQL** | All data storage — events, bookings, tickets, users |
| **Row Level Security (RLS)** | Database-level authorization — users can only access their own data |
| **RPC Functions** | Atomic transactions for booking (prevents overselling) |
| **Storage** | Event banner image uploads |
| **Realtime** | Live updates (booking confirmed, event sold out) |
| **Edge Functions** | Serverless TypeScript functions (email confirmations, payment webhooks) |

### Riverpod (State Management)
Riverpod is a reactive state management library for Flutter. Unlike Provider (its predecessor), Riverpod is:
- **Compile-time safe** — no runtime exceptions from missing providers.
- **Testable** — providers can be overridden in tests.
- We use `@riverpod` code generation to auto-generate boilerplate.

### go_router (Navigation)
A declarative routing library for Flutter. Instead of imperative `Navigator.push()`, routes are defined as a tree with URL paths (e.g., `/attendee/event/:id/checkout`). This enables:
- **Deep linking** from notifications.
- **Auth guards** — redirect to login if not authenticated.
- Clean URL structure for debugging.

### Freezed (Data Modeling)
Freezed is a code generation tool that creates immutable data classes. Instead of writing `copyWith`, `==`, `hashCode`, `toString` manually, we annotate a class with `@freezed` and run `build_runner` to generate them. It also provides union types (sealed classes) for representing states.

### fl_chart (Analytics Visualization)
A Flutter charting library used to draw bar charts and pie charts in the Organizer Analytics Dashboard. Data comes from a pre-aggregated SQL view (`v_event_stats`) to avoid heavy queries.

### qr_flutter & mobile_scanner
- `qr_flutter`: Renders a QR code image from a string on screen. Used to display the digital ticket QR code.
- `mobile_scanner`: Accesses the device camera and decodes QR codes in real-time. Used by organizers to scan tickets at the venue.

---

## 4. Architecture Deep Dive

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  UI (Screens)│  │   Providers  │  │  Repositories│  │
│  │  - Widgets   │◀─│  (Riverpod)  │◀─│  (Data Layer)│  │
│  │  - go_router │  │  - State     │  │  - Supabase  │  │
│  └──────────────┘  └──────────────┘  └──────┬───────┘  │
└──────────────────────────────────────────────┼──────────┘
                                               │ HTTPS
                                               ▼
┌─────────────────────────────────────────────────────────┐
│                   Supabase                              │
│  ┌─────────┐  ┌──────────┐  ┌─────────┐  ┌──────────┐  │
│  │  Auth   │  │ Postgres │  │ Storage │  │ Realtime │  │
│  │  (JWT)  │  │  + RLS   │  │(Banners)│  │(Updates) │  │
│  └─────────┘  └────┬─────┘  └─────────┘  └──────────┘  │
│                    │                                    │
│           ┌────────┴──────────┐                        │
│           │  RPC Functions    │                        │
│           │  - book_ticket()  │                        │
│           │  - check_in()     │                        │
│           └───────────────────┘                        │
└─────────────────────────────────────────────────────────┘
```

### Layer-by-layer explanation:
1. **UI Layer (Screens)**: Pure Flutter widgets. They watch providers for data and call methods on repositories. They contain zero business logic.
2. **Provider Layer (Riverpod)**: Holds application state. For example, `authControllerProvider` holds the current logged-in user and exposes `signIn()`, `signOut()` methods.
3. **Repository Layer**: All data access lives here. Repositories call Supabase APIs. For example, `BookingRepository.bookTicket()` calls the `book_ticket` RPC.

---

## 5. Database Design

### Why PostgreSQL?
PostgreSQL is one of the most reliable relational databases. We chose it because:
- **ACID transactions** guarantee correctness (critical for ticket booking — no overselling).
- **Row Level Security** allows database-level access control.
- **`pg_cron`** extension enables scheduled jobs (expire unpaid bookings after 10 minutes).

### Key Tables

| Table | Purpose |
|---|---|
| `users` | Extends Supabase auth. Stores name, role (attendee/organizer/admin). |
| `events` | One row per event. Has `total_sold` as a denormalized counter for fast reads. |
| `ticket_types` | Pricing tiers per event (e.g., Early Bird ₹500, VIP ₹2000). |
| `bookings` | One row per booking. Uses `SELECT ... FOR UPDATE` to prevent race conditions. |
| `checkins` | Audit log of every QR scan at the venue. |
| `promo_codes` | Discount codes per event with usage limits and expiry. |
| `waitlist` | Queue of users waiting for sold-out events. |
| `refunds` | Refund requests with pending/approved/rejected status. |

### The `book_ticket` RPC — Why it matters
This is the most critical piece of the system. A naive implementation would:
1. Check if seats are available (SELECT).
2. Create a booking (INSERT).

This has a **race condition** — two users can both see "1 seat left" at the same time and both book it, causing overselling.

Our RPC uses `SELECT ... FOR UPDATE` which **locks the row** while the transaction runs:
```sql
SELECT quantity_total - quantity_sold, price
FROM ticket_types
WHERE id = p_ticket_type_id
FOR UPDATE;  -- 🔒 Locks this row
```
This serializes concurrent bookings — the second user waits until the first transaction commits before reading the count.

---

## 6. Key Features & How They Work

### Authentication & Role-Based Access
1. User signs in via Supabase Auth (email/password).
2. A JWT (JSON Web Token) is returned and stored on the device.
3. Every Supabase API call sends this JWT in the Authorization header.
4. RLS policies on the database check `auth.uid()` to ensure users only access their own data.
5. Our `app_router.dart` reads the user's `role` and redirects: attendee → browse, organizer → dashboard, admin → admin panel.

### QR Code Ticket System
1. When a booking is confirmed, the server generates a random 24-byte hex `qr_token`.
2. The attendee's app displays a QR code encoding: `EVT:{event_id}|BK:{booking_id}|T:{qr_token}`.
3. At the venue, the organizer scans this QR using `mobile_scanner`.
4. The app calls the `check_in` RPC which does a **conditional update**: `UPDATE bookings SET status='checked_in' WHERE id=? AND status='confirmed'`.
5. If the update affects 0 rows (already checked in or invalid), it returns `ALREADY_USED_OR_INVALID` — preventing double-entry.

### Promo Code System
1. Organizer creates a code with flat-amount or percentage discount via the Promo Manager screen.
2. Attendee enters the code at checkout.
3. The app calls `validatePromoCode` to check: is it valid for this event? Is it expired? Are uses remaining?
4. The discount is displayed live in the UI.
5. At booking time, the `book_ticket` RPC atomically validates the code again and increments `uses` — preventing race conditions where two people use the last slot of a code simultaneously.

### Email Confirmations (Edge Function)
1. A **database webhook** in Supabase watches the `bookings` table for `UPDATE` events.
2. When a booking's status changes to `confirmed`, Supabase triggers our Edge Function.
3. The Edge Function fetches event & user details, then calls the **Resend API** to send an HTML email with booking details.

---

## 7. State Management — Riverpod

We use **Riverpod 2.x with code generation** (`@riverpod` annotation). Here's the flow:

```dart
// Repository (data source)
@riverpod
EventRepository eventRepository(Ref ref) {
  return EventRepository(ref.watch(supabaseClientProvider));
}

// Async provider (fetches data)
@riverpod
Future<List<Event>> publishedEvents(Ref ref) {
  return ref.watch(eventRepositoryProvider).getPublishedEvents();
}

// UI (consumes data)
class BrowseScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(publishedEventsProvider); // AsyncValue<List<Event>>
    return events.when(
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (list) => ListView(children: list.map(...).toList()),
    );
  }
}
```

The `ref.watch()` creates a reactive subscription — whenever the underlying data changes, the widget automatically rebuilds.

---

## 8. Security

| Threat | How we mitigate it |
|---|---|
| **Unauthorized data access** | Row Level Security (RLS) on all tables at the DB level |
| **API key exposure** | Only the public `anon` key is in the app. Service role key is NEVER shipped to the client. |
| **Overselling** | `SELECT ... FOR UPDATE` in the booking RPC |
| **Double check-in** | Conditional UPDATE in the `check_in` RPC |
| **Payment fraud** | Payment confirmation verified via webhook signature on the server, never via client callback |
| **Promo code abuse** | `uses` column incremented atomically inside the booking RPC transaction |
| **.env not committed** | `.gitignore` excludes `.env`. All secrets via environment variables. |

---

## 9. What is Implemented (v1.0 + v1.1)

### v1.0 — Core MVP ✅
- [x] Role-based authentication (Attendee / Organizer / Admin)
- [x] Organizer: Create events with banner, description, venue, date
- [x] Organizer: Define multiple ticket tiers (name, price, inventory)
- [x] Attendee: Browse and search published events
- [x] Attendee: Book tickets with atomic inventory guarantee (RPC)
- [x] Attendee: View QR-coded digital tickets
- [x] Organizer: Scan QR codes for venue check-in
- [x] Organizer: Per-event analytics dashboard (revenue, attendance chart)
- [x] Admin: Dashboard stub

### v1.1 — Extended Features ✅
- [x] Promo Codes: Organizers create flat/percent discount codes with usage limits
- [x] Promo Codes: Attendees apply codes at checkout with live discount preview
- [x] Waitlist: Attendees join/leave waitlist for sold-out events
- [x] Refund Workflow: Attendees request refunds; Organizers approve/reject
- [x] Email Confirmations: Supabase Edge Function sends HTML booking confirmation emails

### v1.2 — Full Completion ✅
- [x] **Admin Event Approvals**: Full review workflow to Approve or Reject submitted events
- [x] **Admin Platform Stats**: Real-time KPI dashboard (Total Users, Events, Bookings, Platform Revenue)
- [x] **Admin User Management**: Search users and promote/demote roles (Attendee / Organizer / Admin)
- [x] **Reviews & Ratings**: Attendees leave 1-5 star ratings & comments; average score on event header
- [x] **Organizer Attendee Roster**: Complete attendee table with check-in badges and one-tap CSV Export
- [x] **Interactive Payment Gateway**: Simulated checkout sheet (UPI, Cards, Net Banking) with secure processing
- [x] **Offline Scanner Sync**: Pre-cache ticket tokens for offline scanning at venues + automatic cloud sync
- [x] **Zero-Warning Code Quality**: Flutter analyze passes with 0 errors and 0 warnings, automated unit tests

---

## 10. What is Left (Roadmap)

### Future Enhancements (v1.3+)
| Feature | Description | Complexity |
|---|---|---|
| 🪑 Seat Selection | Visual seat map UI (like BookMyShow). Users pick specific seats | High |
| 👥 Group Bookings | Book for multiple attendees with individual QR codes per person | Medium |
| 💱 Multi-Currency | Support INR, USD, EUR etc. using currency detection | Low |
| 💸 Organizer Payouts | Scheduled payout to organizer's bank account after event | High |
| 🔔 Push Notifications | FCM notifications for event reminders, booking updates, waitlist alerts | Medium |
| 📅 Calendar Integration | Add event to Google/Apple Calendar | Low |

### v1.3 — Platform Growth
| Feature | Description | Complexity |
|---|---|---|
| 🔔 Push Notifications | FCM notifications for event reminders, booking updates, waitlist alerts | Medium |
| ⭐ Reviews & Ratings | Post-event attendee reviews and star ratings | Low |
| 🎟️ Transfer Tickets | Attendee can transfer/gift a ticket to another user | Medium |
| 📅 Calendar Integration | Add event to Google/Apple Calendar | Low |
| 📊 CSV Export | Organizer can download booking data as CSV | Low |

### v2.0 — Platform Features
| Feature | Description | Complexity |
|---|---|---|
| 🌐 Public API | REST API for third-party ticketing integrations | High |
| 🎥 Live Streaming | In-app event live stream for hybrid events | Very High |
| 🤖 Recommendations | ML-based event suggestions based on user history | High |
| 🏢 White-Label | Multi-tenant support for organizations to run their own branded instance | Very High |
| 🪑 Virtual Venue | 3D interactive venue for online events | Very High |

### Backend / DevOps Left
| Item | Status |
|---|---|
| Payment Gateway integration (Razorpay/Stripe) | ⬜ Not started |
| Admin: Approve/Reject submitted events | ⬜ Not started |
| Admin: Manage users & roles | ⬜ Not started |
| Admin: Platform-wide metrics (materialized views) | ⬜ Not started |
| Offline scanner sync (IndexedDB cache for QR validation) | ⬜ Not started |
| `pg_cron` job for booking expiry (10 min timeout) | ⬜ Not started |
| Full RLS policies for all tables | ⬜ Not started |
| Supabase Storage for banner image upload | ⬜ Not started |

---

## 11. Common Viva Questions & Answers

**Q: Why Flutter over React Native?**
> Flutter uses its own rendering engine (Skia/Impeller), meaning it doesn't depend on platform UI components. This gives pixel-perfect, consistent UI across iOS and Android. React Native bridges to native components, which can cause inconsistencies. Flutter's performance is also generally superior for animation-heavy UIs.

**Q: Why Supabase over Firebase?**
> Supabase uses PostgreSQL, a relational database, which is far more powerful for complex queries, joins, and transactional guarantees. Firebase uses Firestore (NoSQL), which cannot easily do transactions across multiple documents needed for inventory management. Supabase is also open-source and can be self-hosted.

**Q: What is Row Level Security?**
> RLS is a PostgreSQL feature that enforces access control at the database level. Even if someone bypasses our app and calls the API directly with a valid JWT, they cannot read or modify another user's data. For example: `CREATE POLICY "Users see own bookings" ON bookings FOR SELECT USING (auth.uid() = user_id);`

**Q: How do you prevent two people from booking the last ticket?**
> We use a Postgres RPC function with `SELECT ... FOR UPDATE`. This places a row-level lock on the `ticket_types` row during the transaction. Any concurrent attempt to book the same tier waits for the lock to be released, then reads the updated count. This is a classic **pessimistic locking** approach.

**Q: What is an idempotency key?**
> An idempotency key is a unique identifier sent with a request to ensure it can be safely retried. If a network error occurs after booking but before the client receives the response, the app can retry with the same key. The RPC checks if the key already exists and returns the existing booking instead of creating a duplicate.

**Q: What is Riverpod and why use it?**
> Riverpod is a state management library that makes data fetching, caching, and reactivity declarative. When a provider's data changes (e.g., a new booking is made), all widgets watching that provider automatically rebuild. It's compile-time safe (unlike Provider) and makes testing easy through dependency injection via provider overrides.

**Q: How does the QR scanner work offline?**
> The scanner uses `mobile_scanner` to read the device camera. The QR encodes `EVT:{id}|BK:{id}|T:{token}`. For offline support (venue with poor WiFi), the organizer can pre-download the list of valid booking IDs and tokens for their event. The scanner validates against this local cache and syncs check-ins to Supabase when connectivity returns.
