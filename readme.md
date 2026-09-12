# EventHub — Online Event Management & Ticket Booking System

A cross-platform Flutter application for creating, publishing, and booking event tickets, with built-in analytics for organizers and monitoring tools for admins.

Organizers publish events and ticket tiers. Attendees browse, book, and pay. Every confirmed booking generates a QR ticket that is scanned at the venue. All revenue, sell-through, and attendance data rolls up into dashboards for organizers and platform admins.

---

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Data Model](#data-model)
- [Booking Workflow](#booking-workflow)
- [Check-In & QR Tickets](#check-in--qr-tickets)
- [Analytics & Reports](#analytics--reports)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [Database Setup](#database-setup)
- [Running the App](#running-the-app)
- [Testing](#testing)
- [Deployment](#deployment)
- [Security & RLS](#security--rls)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## Features

### Attendee
- Browse and search events by category, city, and date
- View event details, venue, ticket tiers, and availability in real time
- Book one or more tickets with atomic inventory guarantees
- Pay via Razorpay / Stripe
- Receive a QR-coded digital ticket
- View booking history, cancel eligible bookings, request refunds
- Push notifications for event reminders and updates

### Organizer
- Create, edit, and publish events with banner images
- Define multiple ticket tiers (Early Bird, VIP, General) with per-tier inventory and sale windows
- Real-time sales dashboard (revenue, tickets sold, sell-through rate)
- On-site QR scanner for attendee check-in (works offline)
- Per-event attendance reports and CSV export

### Admin
- Approve or reject submitted events before publishing
- Manage users, organizers, and roles
- Platform-wide revenue, bookings, and attendance metrics
- Refund oversight and audit log
- Category and city management

---

## Screenshots

> Replace with actual screenshots after your first build.

| Attendee Browse | Event Detail | QR Ticket | Organizer Analytics | Admin Dashboard |
|---|---|---|---|---|
| `docs/screens/browse.png` | `docs/screens/detail.png` | `docs/screens/ticket.png` | `docs/screens/analytics.png` | `docs/screens/admin.png` |

---

## Architecture

```
┌──────────────────────────────────────────────────────┐
│                  Flutter Client                      │
│  ┌──────────┐  ┌───────────┐  ┌───────────────────┐  │
│  │ Attendee │  │ Organizer │  │      Admin        │  │
│  └────┬─────┘  └─────┬─────┘  └─────────┬─────────┘  │
│       │              │                  │            │
│       └──────────────┼──────────────────┘            │
│                      ▼                               │
│         Repository Layer (data access)               │
│                      │                               │
│         Riverpod Providers (state)                   │
└──────────────────────┼───────────────────────────────┘
                       │ HTTPS / Realtime
                       ▼
┌──────────────────────────────────────────────────────┐
│              Backend (Supabase)                      │
│  ┌─────────┐ ┌──────────┐ ┌────────┐ ┌────────────┐  │
│  │  Auth   │ │ Postgres │ │Storage │ │  Realtime  │  │
│  └─────────┘ └────┬─────┘ └────────┘ └────────────┘  │
│                   │                                  │
│         RPC functions (booking, check-in)            │
│         Row Level Security policies                  │
│         pg_cron jobs (booking expiry)                │
└──────────────────────┬───────────────────────────────┘
                       │ Webhooks
                       ▼
              Payment Gateway (Razorpay/Stripe)
```

**Design principles:**
1. All business rules live server-side (RPCs + RLS), never in the client.
2. Inventory mutations are transactional and idempotent.
3. Analytics are pre-aggregated; the UI never runs heavy `count(*)` queries.
4. The scanner works offline and syncs when connectivity returns.

---

## Tech Stack

**Client**
- Flutter 3.19+ / Dart 3.3+
- Riverpod 2.x — state management
- go_router — declarative routing
- fl_chart — analytics visualization
- qr_flutter — QR ticket rendering
- mobile_scanner — check-in scanning
- cached_network_image, image_picker, intl, freezed, json_serializable

**Backend**
- Supabase (Postgres 15, Auth, Storage, Realtime, Edge Functions)
- pg_cron — scheduled booking expiry
- Razorpay or Stripe — payments

**Tooling**
- Melos (if multi-package)
- Very Good CLI / FlutterFire CLI
- GitHub Actions — CI (analyze, test, build)

---

## Data Model

```sql
-- Users (extends Supabase auth.users)
users(
  id            uuid pk references auth.users,
  name          text,
  email         text,
  phone         text,
  role          text check (role in ('attendee','organizer','admin')),
  fcm_token     text,
  created_at    timestamptz default now()
);

-- Events
events(
  id            uuid pk,
  organizer_id  uuid references users,
  title         text,
  description   text,
  venue         text,
  city          text,
  start_at      timestamptz,
  end_at        timestamptz,
  banner_url    text,
  category      text,
  status        text default 'draft',  -- draft|pending|published|cancelled|completed
  total_sold    int default 0,          -- denormalized counter
  gross_revenue numeric default 0,
  created_at    timestamptz default now()
);

-- Ticket tiers
ticket_types(
  id             uuid pk,
  event_id       uuid references events,
  name           text,
  price          numeric,
  quantity_total int,
  quantity_sold  int default 0,
  sales_start    timestamptz,
  sales_end      timestamptz
);

-- Bookings
bookings(
  id              uuid pk,
  user_id         uuid references users,
  event_id        uuid references events,
  ticket_type_id  uuid references ticket_types,
  quantity        int,
  unit_price      numeric,
  total_amount    numeric,
  status          text default 'pending_payment',
                  -- pending_payment|confirmed|checked_in|cancelled|expired|refunded
  idempotency_key text unique,
  qr_token        text,
  created_at      timestamptz default now()
);

-- Check-ins
checkins(
  id          uuid pk,
  booking_id  uuid references bookings,
  scanned_at  timestamptz default now(),
  scanned_by  uuid references users
);

-- Payments
payments(
  id            uuid pk,
  booking_id    uuid references bookings,
  provider      text,
  provider_ref  text,
  amount        numeric,
  status        text,
  created_at    timestamptz default now()
);
```

---

## Booking Workflow

Inventory integrity is the core requirement. Bookings are created through an **atomic Postgres function**, never via direct client inserts.

```
Client                  Backend                        Payment Gateway
  │                        │                                │
  │─ book_ticket() ───────▶│                                │
  │                        │ 1. Check idempotency key       │
  │                        │ 2. SELECT ... FOR UPDATE       │
  │                        │    on ticket_types row         │
  │                        │ 3. Validate remaining qty      │
  │                        │ 4. Increment quantity_sold     │
  │                        │ 5. Insert booking              │
  │◀─ booking_id ──────────│    (status=pending_payment)    │
  │                        │                                │
  │─ create payment order ─┼───────────────────────────────▶│
  │◀─ checkout session ────┼────────────────────────────────│
  │                        │                                │
  │  (user pays)           │                                │
  │                        │◀── webhook: payment.captured ──│
  │                        │ 6. Verify signature            │
  │                        │ 7. UPDATE booking → confirmed  │
  │                        │ 8. UPDATE events totals        │
  │◀─ realtime: confirmed ─│                                │
```

**Key guarantees:**
- `SELECT ... FOR UPDATE` serializes concurrent bookings on the same tier — no overselling.
- `idempotency_key` prevents duplicate bookings from retries.
- Payment confirmation is verified via webhook, never client callback.
- Unpaid bookings expire after 10 minutes via `pg_cron`, releasing seats.

**RPC:**
```sql
create or replace function book_ticket(
  p_ticket_type_id uuid,
  p_qty            int,
  p_user_id        uuid,
  p_idem           text
) returns uuid
language plpgsql security definer as $$
declare
  v_remaining int;
  v_price     numeric;
  v_booking   uuid;
begin
  select id into v_booking from bookings where idempotency_key = p_idem;
  if found then return v_booking; end if;

  select quantity_total - quantity_sold, price
    into v_remaining, v_price
  from ticket_types
  where id = p_ticket_type_id
  for update;

  if v_remaining < p_qty then
    raise exception 'SOLD_OUT' using errcode = 'P0001';
  end if;

  update ticket_types
     set quantity_sold = quantity_sold + p_qty
   where id = p_ticket_type_id;

  insert into bookings (user_id, ticket_type_id, quantity, unit_price,
                        total_amount, status, idempotency_key, qr_token)
  values (p_user_id, p_ticket_type_id, p_qty, v_price, v_price * p_qty,
          'pending_payment', p_idem, encode(gen_random_bytes(24), 'hex'))
  returning id into v_booking;

  return v_booking;
end $$;
```

---

## Check-In & QR Tickets

Each confirmed booking stores a server-generated `qr_token`. The attendee's ticket QR encodes:

```
EVT:{event_id}|BK:{booking_id}|T:{qr_token}
```

**Double-scan protection** uses a conditional update — atomic without locks:

```sql
create or replace function check_in(p_booking_id uuid, p_staff uuid)
returns text language plpgsql security definer as $$
declare v_status text;
begin
  update bookings
     set status = 'checked_in'
   where id = p_booking_id and status = 'confirmed'
  returning status into v_status;

  if v_status is null then
    return 'ALREADY_USED_OR_INVALID';
  end if;

  insert into checkins(booking_id, scanned_by) values (p_booking_id, p_staff);
  return 'OK';
end $$;
```

The scanner caches the event's valid booking list on-device so check-in continues during venue Wi-Fi outages, then syncs on reconnect.

---

## Analytics & Reports

Three tiers of aggregation, so the UI stays fast at scale:

1. **Live counters** — `events.total_sold` and `events.gross_revenue` are incremented in the same transaction that confirms a booking.
2. **SQL views** — for per-event reports:

```sql
create view v_event_stats as
select e.id, e.title,
       count(b.id) filter (where b.status in ('confirmed','checked_in')) as tickets_sold,
       sum(b.total_amount) filter (where b.status in ('confirmed','checked_in')) as revenue,
       count(b.id) filter (where b.status = 'checked_in') as attended,
       round(100.0 * count(b.id) filter (where b.status='checked_in')
             / nullif(count(b.id) filter (where b.status in ('confirmed','checked_in')),0), 1) as attendance_rate
from events e left join bookings b on b.event_id = e.id
group by e.id, e.title;
```

3. **Materialized views** — nightly rollups for the admin dashboard.

**Charts built with `fl_chart`:**
- Revenue and tickets sold over time (line)
- Sell-through by ticket tier (horizontal bar)
- Attendance rate gauge
- Bookings by city / category (pie)

Organizers can export any report to CSV.

---

## Project Structure

```
eventhub/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── theme/           # colors, typography, dark mode
│   │   ├── router/          # go_router config + guards
│   │   ├── api/             # supabase client, interceptors
│   │   ├── errors/          # failure types, handlers
│   │   └── utils/           # formatters, validators, date helpers
│   ├── models/              # freezed data classes
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── event_repository.dart
│   │   ├── booking_repository.dart
│   │   └── analytics_repository.dart
│   ├── providers/           # riverpod notifiers
│   └── features/
│       ├── auth/
│       ├── attendee/
│       │   ├── browse/
│       │   ├── event_detail/
│       │   ├── checkout/
│       │   ├── my_tickets/
│       │   └── ticket_qr/
│       ├── organizer/
│       │   ├── dashboard/
│       │   ├── create_event/
│       │   ├── ticket_tiers/
│       │   ├── scanner/
│       │   └── analytics/
│       └── admin/
│           ├── approvals/
│           ├── users/
│           └── platform_stats/
├── supabase/
│   ├── migrations/
│   ├── functions/           # edge functions (webhooks, expiry)
│   └── seed.sql
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── docs/
│   └── screens/
├── .env.example
├── pubspec.yaml
└── README.md
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.19+ (`flutter --version`)
- Dart 3.3+
- A Supabase project (free tier is fine)
- Razorpay or Stripe account (test mode)
- Node.js 18+ (only for Supabase CLI)

### Clone and install
```bash
git clone https://github.com/your-org/eventhub.git
cd eventhub
flutter pub get
```

---

## Environment Variables

Create a `.env` file from the template:

```bash
cp .env.example .env
```

`.env.example`:
```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
RAZORPAY_KEY_ID=rzp_test_xxxxx
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxx
APP_ENV=development
```

Load with `flutter_dotenv` in `main.dart`:
```dart
await dotenv.load(fileName: ".env");
```

> **Never commit `.env`.** Add it to `.gitignore`. Only the public anon key belongs in the client; the service role key stays on the server.

---

## Database Setup

Using the Supabase CLI:

```bash
# Link to your project
supabase link --project-ref your-project-ref

# Apply migrations
supabase db push

# Seed sample data (optional)
supabase db execute --file supabase/seed.sql
```

Migrations to run in order:
1. `001_users.sql` — users table, role enum
2. `002_events.sql` — events table
3. `003_ticket_types.sql` — ticket tiers
4. `004_bookings.sql` — bookings, payments
5. `005_checkins.sql` — check-ins
6. `006_rpc.sql` — `book_ticket`, `check_in` functions
7. `007_views.sql` — analytics views
8. `008_rls.sql` — row level security policies
9. `009_cron.sql` — booking expiry job

Deploy edge functions:
```bash
supabase functions deploy payment-webhook
supabase functions deploy expire-bookings
```

---

## Running the App

```bash
# Debug
flutter run

# Specific device
flutter run -d chrome        # web
flutter run -d macos         # desktop
flutter run -d <device-id>   # mobile

# Release build
flutter build apk --release
flutter build ipa --release
flutter build web --release
```

---

## Testing

```bash
# Static analysis
flutter analyze

# Unit + widget tests
flutter test

# Integration tests
flutter test integration_test/

# Concurrency test for the booking RPC (critical)
dart run test/concurrency/booking_race_test.dart
```

**The concurrency test** fires 50 parallel bookings against a 10-seat tier and asserts exactly 10 succeed and 40 fail with `SOLD_OUT`. Run this before every release — it's the single best guard against overselling.

---

## Deployment

### Backend
- Migrations and functions deploy via `supabase db push` and `supabase functions deploy`.
- Set up the payment provider webhook to point at your deployed `payment-webhook` function URL.
- Configure `pg_cron` for the booking expiry job (runs every minute).

### Client
- **Android:** `flutter build appbundle --release` → upload to Play Console.
- **iOS:** `flutter build ipa --release` → upload via Transporter or Xcode.
- **Web:** `flutter build web --release` → deploy `build/web` to Vercel, Netlify, or Firebase Hosting.

### CI (GitHub Actions)
```yaml
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.19.0' }
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

---

## Security & RLS

Row Level Security is enabled on every table. Key policies:

| Table | Policy |
|---|---|
| `users` | Users read/update only their own row. Admins read all. |
| `events` | Public read for `status = 'published'`. Organizers manage their own. Admins manage all. |
| `ticket_types` | Public read. Only the owning organizer can write. |
| `bookings` | Attendees read their own. Organizers read bookings for their events. |
| `checkins` | Organizers read check-ins for their events only. |
| `payments` | Owner read only. Server functions write. |

Additional hardening:
- Service role key is **never** shipped to the client.
- Payment confirmation always verified server-side via webhook signature.
- `qr_token` is random 24-byte hex; it's the only thing that validates a ticket.
- Rate limiting on booking RPC per user (10 attempts/min).

---

## Roadmap

**v1.0 (MVP)**
- [x] Auth with roles
- [x] Event creation and publishing
- [x] Atomic booking + payment
- [x] QR ticket + scanner
- [x] Basic analytics dashboards

**v1.1**
- [ ] Refund workflow with partial refunds
- [ ] Promo codes and discounts
- [ ] Waitlist for sold-out events
- [ ] Email confirmations

**v1.2**
- [ ] Seat selection with visual seat map
- [ ] Group bookings
- [ ] Multi-currency
- [ ] Organizer payout scheduling

**v2.0**
- [ ] Public API for third-party integrations
- [ ] Event live streaming integration
- [ ] Recommendation engine
- [ ] White-label tenant support

---

## Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature`.
3. Commit using conventional commits: `feat: add promo code support`.
4. Run `flutter analyze` and `flutter test` before pushing.
5. Open a pull request against `main`.

Please open an issue first for any significant change.

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

## Acknowledgements

- [Supabase](https://supabase.com) — backend platform
- [Flutter](https://flutter.dev) — UI framework
- [Riverpod](https://riverpod.dev) — state management
- [fl_chart](https://pub.dev/packages/fl_chart) — charting

---

**Built with Flutter & Supabase.** 