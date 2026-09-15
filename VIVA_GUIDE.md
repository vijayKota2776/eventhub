# EventHub — Project Viva & Technical Documentation

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Problem Statement](#2-problem-statement)
3. [Tech Stack — Explained](#3-tech-stack--explained)
4. [Architecture Deep Dive](#4-architecture-deep-dive)
5. [Database Design & Schemas](#5-database-design--schemas)
6. [Key Features & Technical Implementation](#6-key-features--technical-implementation)
7. [State Management — Riverpod 3](#7-state-management--riverpod-3)
8. [Concurrency & Security (RLS & RPCs)](#8-concurrency--security-rls--rpcs)
9. [Implemented Feature Roadmap (v1.0 → v2.0)](#9-implemented-feature-roadmap-v10--v20)
10. [How to Build & Generate .APK File (GitHub Actions)](#10-how-to-build--generate-apk-file-github-actions)
11. [Comprehensive Viva Questions & Answers](#11-comprehensive-viva-questions--answers)

---

## 1. Project Overview

**EventHub** is a production-grade, full-stack cross-platform mobile and desktop application for end-to-end event discovery, ticketing, seat allocation, check-in scanning, and organizer payout management.

- **Frontend**: Flutter 3.27+ with Material 3 design, dynamic currency switching, and smooth animations.
- **Backend**: Supabase (PostgreSQL 15+, Row Level Security, RPC Transactions, Edge Functions, Storage).
- **State Management**: Riverpod 3 with Code Generation (`@riverpod`, `Notifier`, `AsyncNotifier`).
- **DevOps**: Automated CI/CD via GitHub Actions for building release APKs.

---

## 2. Problem Statement

Traditional commercial event ticketing platforms (e.g. BookMyShow, Eventbrite) suffer from:
1. **High Commission Fees**: 10-20% platform cut on every ticket sold.
2. **Race Conditions & Overselling**: Network latency and concurrency bugs leading to overbooked seats.
3. **No Offline Check-In**: Poor internet connectivity at physical venues breaks entrance validation.
4. **Rigid Pricing & Single-Currency Constraints**: Lack of real-time multi-currency display and group booking support.

**EventHub** solves all four issues using:
- Self-hosted / serverless infrastructure on Supabase for zero platform fee overhead.
- **Pessimistic locking** via PostgreSQL `SELECT ... FOR UPDATE` stored procedures for 100% oversell prevention.
- **Local sqlite / cached offline scanner** with automatic cloud synchronization.
- Real-time exchange rate calculation, group booking forms, and organizer financial payout controls.

---

## 3. Tech Stack — Explained

### Flutter (Frontend)
- **Single Codebase**: Compiles to native ARM machine code for iOS, Android, macOS, Windows, Linux, and Web.
- **Material 3 System**: Dynamic seed colors, glassmorphic dark theme, custom slivers, smooth hero animations.
- **Riverpod 3**: Declarative state management with compile-time safety and automatic caching.

### Supabase (Backend)
| Component | Functionality |
|---|---|
| **PostgreSQL Database** | Relational data integrity, foreign keys, triggers, RPC procedures |
| **Row Level Security (RLS)** | Database-level authorization rules per role (`attendee`, `organizer`, `admin`) |
| **Atomic Stored Procedures** | `book_ticket()` handles inventory decrement + booking creation atomically |
| **Supabase Storage** | Public buckets (`event-banners`) for event poster uploads via `image_picker` |
| **Realtime** | WebSocket streams for live ticket tier inventory and booking status |

---

## 4. Architecture Deep Dive

```
 ┌─────────────────────────────────────────────────────────┐
 │                   Flutter Frontend UI                   │
 │ (BrowseScreen, EventDetailScreen, SeatSelection, etc.) │
 └────────────────────────────┬────────────────────────────┘
                              │
                    Riverpod Providers
                              │
 ┌────────────────────────────▼────────────────────────────┐
 │                 Repository Layer (Data)                 │
 │ (EventRepo, BookingRepo, RecommendationRepo, AuthRepo) │
 └────────────────────────────┬────────────────────────────┘
                              │
                     Supabase SDK (Dart)
                              │
 ┌────────────────────────────▼────────────────────────────┐
 │                    Supabase Backend                     │
 │  ┌──────────────┐   ┌───────────────┐   ┌────────────┐  │
 │  │ Postgres RLS │   │ Stored Funcs  │   │ Storage    │  │
 │  │ Security     │   │ (book_ticket) │   │ (Banners)  │  │
 │  └──────────────┘   └───────────────┘   └────────────┘  │
 └─────────────────────────────────────────────────────────┘
```

---

## 5. Database Design & Schemas

### Core Tables
1. **`users`**: `id` (UUID, FK to `auth.users`), `name`, `email`, `role` (`attendee` | `organizer` | `admin`), `avatar_url`.
2. **`events`**: `id`, `organizer_id`, `title`, `description`, `venue`, `city`, `start_at`, `end_at`, `category`, `banner_url`, `status` (`draft` | `published` | `rejected`), `total_sold`, `gross_revenue`.
3. **`ticket_types`**: `id`, `event_id`, `name` (e.g., VIP, General), `price`, `total_qty`, `available_qty`.
4. **`bookings`**: `id`, `event_id`, `user_id`, `ticket_type_id`, `quantity`, `total_price`, `qr_token`, `status` (`confirmed` | `cancelled` | `refunded`), `idempotency_key`, `created_at`.
5. **`reviews`**: `id`, `event_id`, `user_id`, `user_name`, `rating` (1-5), `comment`, `created_at`.
6. **`payout_requests`**: `id`, `organizer_id`, `amount`, `status` (`pending` | `completed`), `bank_details`, `requested_at`.

---

## 6. Key Features & Technical Implementation

### 1. Smart Recommendation Engine (`RecommendationRepository`)
- Queries user's past booking history to analyze preferred categories and cities.
- Queries active events matching user preferences, with a client-side ranking algorithm.
- Fallback to top-trending events ordered by `total_sold` when history is sparse.

### 2. Interactive Seat Selection (`SeatSelectionScreen`)
- Dynamic 2D seat map builder supporting VIP, Premium, and Standard rows.
- Interactive seat selection with real-time price summary calculation.
- Passes array of selected seat IDs directly to checkout pipeline.

### 3. Group Bookings (`GroupBookingScreen` & `GroupTicketListScreen`)
- Dynamic attendee list generator allowing users to book tickets for multiple people simultaneously.
- Generates individual, unique encrypted QR codes (`EVT:{id}|BK:{id}|T:{token}`) for each attendee.
- Displays full group ticket carousel with single-tap QR enlargement.

### 4. Multi-Currency Engine (`CurrencyNotifier`)
- Riverpod state notifier supporting **USD ($)**, **INR (₹)**, **EUR (€)**, **GBP (£)**, and **JPY (¥)**.
- Formats all prices across the platform dynamically with real-time conversion rates.

### 5. Financial Payout Dashboard (`PayoutDashboardScreen`)
- Financial analytics panel for organizers displaying Gross Revenue, Platform Fees (5%), Net Earnings, and Available Balance.
- Payout request modal with bank account form validation and status tracking.

### 6. Notification Settings (`NotificationSettingsScreen`)
- Preferences screen with toggleable switches grouped under Bookings, Reminders, Discovery, and Promotions.
- Dynamic count badge and "Enable All / Disable All" shortcut.

### 7. Event Banner Upload & Image Picker
- Integration with `image_picker` (Camera/Gallery) in `CreateEventScreen`.
- Uploads binary data to Supabase Storage bucket `event-banners` and links the public URL automatically.

---

## 7. State Management — Riverpod 3

We utilize **Riverpod 3** with code generation (`@riverpod`) to ensure:
- **Compile-time safety**: Providers cannot throw runtime missing-provider errors.
- **Global Reactive Scope**: Auto-refresh UI upon currency change, login state change, or ticket booking completion.
- **Provider Dependencies**:
  ```dart
  @riverpod
  BookingRepository bookingRepository(Ref ref) {
    return BookingRepository(ref.watch(supabaseClientProvider));
  }
  ```

---

## 8. Concurrency & Security (RLS & RPCs)

### Atomic Booking RPC Stored Procedure (`book_ticket`)
```sql
CREATE OR REPLACE FUNCTION book_ticket(
  p_ticket_type_id UUID,
  p_qty INT,
  p_user_id UUID,
  p_idem TEXT
) RETURNS UUID AS $$
DECLARE
  v_available INT;
  v_event_id UUID;
  v_price NUMERIC;
  v_booking_id UUID;
BEGIN
  -- 1. Check idempotency key to prevent double charging
  SELECT id INTO v_booking_id FROM bookings WHERE idempotency_key = p_idem;
  IF FOUND THEN
    RETURN v_booking_id;
  END IF;

  -- 2. Lock row to prevent race conditions (Pessimistic Locking)
  SELECT available_qty, event_id, price INTO v_available, v_event_id, v_price
  FROM ticket_types WHERE id = p_ticket_type_id FOR UPDATE;

  IF v_available < p_qty THEN
    RAISE EXCEPTION 'Not enough tickets available';
  END IF;

  -- 3. Decrement inventory
  UPDATE ticket_types SET available_qty = available_qty - p_qty WHERE id = p_ticket_type_id;

  -- 4. Create booking record
  INSERT INTO bookings (event_id, user_id, ticket_type_id, quantity, total_price, idempotency_key, qr_token, status)
  VALUES (v_event_id, p_user_id, p_ticket_type_id, p_qty, v_price * p_qty, p_idem, md5(random()::text), 'confirmed')
  RETURNING id INTO v_booking_id;

  RETURN v_booking_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 9. Implemented Feature Roadmap (v1.0 → v2.0)

| Phase | Feature | Status |
|---|---|---|
| **v1.0** | Core Authentication, Event Browse, Ticket Booking, QR Generation, Basic Scanner | ✅ Completed |
| **v1.1** | Promo Code Manager, Waitlist System, Attendee Refund Requests | ✅ Completed |
| **v1.2** | Admin Approvals, Platform Analytics, User Role Management, Ratings & Reviews, Payment Simulator, Offline Scanner | ✅ Completed |
| **v1.3** | Interactive Seat Map, Ticket Transfer, Calendar Add & Social Share, Multi-Currency | ✅ Completed |
| **v2.0** | Smart Recommendation Engine, Group Bookings, Payout Dashboard, Banner Upload, Notification Settings | ✅ Completed |

---

## 10. How to Build & Generate .APK File (GitHub Actions)

The repository includes an automated **GitHub Actions CI/CD workflow** (`.github/workflows/build_apk.yml`) that compiles the Flutter app into a standalone Android `.apk` file automatically on every commit.

### How to Download the .APK File from GitHub:
1. Push your repository to GitHub: `git push origin main`.
2. Go to your repository on GitHub: `https://github.com/vijayKota2776/eventhub`.
3. Click on the **Actions** tab at the top.
4. Select the latest workflow run (e.g. `Build Android APK`).
5. Scroll down to the **Artifacts** section at the bottom.
6. Click on **`eventhub-release-apk`** to download the zip file containing `app-release.apk`.
7. Install the `.apk` file directly on any Android device!

### Local Build Command:
```bash
flutter build apk --release
```
The output APK file will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 11. Comprehensive Viva Questions & Answers

**Q1: Why did you choose Flutter over React Native or Native Android?**
> Flutter compiles directly to native ARM machine code without using a JavaScript bridge. This guarantees 60/120 FPS performance and pixel-perfect rendering across platforms using the Impeller/Skia engine.

**Q2: How does the application handle concurrency and race conditions when multiple users book the last ticket simultaneously?**
> We use a custom PostgreSQL RPC function (`book_ticket`) with `SELECT ... FOR UPDATE` pessimistic locking. When a user initiates a booking, the row for that ticket tier is locked at the database level. Other transactions must wait until the lock releases, ensuring zero overselling.

**Q3: How is state management structured in this project?**
> We use **Riverpod 3** with code generation (`@riverpod`). It provides compile-time safe state management, automatic caching, reactive UI updates, and dependency injection across repositories and controllers.

**Q4: How does the QR Code check-in scanner work offline?**
> The scanner app uses `mobile_scanner` to read QR tokens formatted as `EVT:{id}|BK:{id}|T:{token}`. For venues without internet access, ticket tokens are pre-cached in local storage. Validations occur locally and sync to Supabase automatically when connectivity returns.

**Q5: What is Row Level Security (RLS) and why is it used?**
> RLS is a database-level security policy feature in PostgreSQL. It ensures that authorization logic is enforced at the database layer. Even if an attacker bypasses the app API, database policies prevent them from modifying records belonging to other users.

**Q6: What is an Idempotency Key and how is it used in checkout?**
> An idempotency key (UUID v4) is sent with every booking request. If a network disruption occurs mid-transaction, retrying with the same key returns the already-created booking rather than double-charging or creating duplicate tickets.

**Q7: How does the Smart Recommendation system work?**
> `RecommendationRepository` analyzes the user's booking history to extract top categories and cities. It queries upcoming events matching these parameters. If history is insufficient, it automatically falls back to top-trending events ranked by ticket sales.

**Q8: How is Multi-Currency conversion handled?**
> `CurrencyNotifier` manages global currency state (USD, INR, EUR, GBP, JPY). All prices are stored in base currency (USD) in the database and formatted dynamically in real-time across the app UI.
