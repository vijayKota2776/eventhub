-- EventHub Master Database Schema SQL Script
-- Run this script in your Supabase Dashboard -> SQL Editor

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Users Table
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'attendee',
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Events Table
CREATE TABLE IF NOT EXISTS public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organizer_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  venue TEXT NOT NULL,
  city TEXT NOT NULL,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ NOT NULL,
  category TEXT NOT NULL DEFAULT 'General',
  banner_url TEXT,
  status TEXT NOT NULL DEFAULT 'published', -- 'draft', 'pending_approval', 'published', 'rejected'
  total_sold INT DEFAULT 0,
  gross_revenue NUMERIC DEFAULT 0.0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Ticket Types Table
CREATE TABLE IF NOT EXISTS public.ticket_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  price NUMERIC NOT NULL DEFAULT 0.0,
  quantity_total INT NOT NULL,
  quantity_sold INT DEFAULT 0,
  sales_start TIMESTAMPTZ DEFAULT NOW(),
  sales_end TIMESTAMPTZ DEFAULT NOW() + INTERVAL '30 days',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Bookings Table
CREATE TABLE IF NOT EXISTS public.bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
  ticket_type_id UUID REFERENCES public.ticket_types(id) ON DELETE CASCADE NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  unit_price NUMERIC NOT NULL DEFAULT 0.0,
  total_amount NUMERIC NOT NULL DEFAULT 0.0,
  qr_token TEXT NOT NULL UNIQUE,
  status TEXT DEFAULT 'confirmed', -- 'confirmed', 'cancelled', 'refunded'
  idempotency_key TEXT UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Promo Codes Table
CREATE TABLE IF NOT EXISTS public.promo_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
  code TEXT NOT NULL,
  discount_amount NUMERIC,
  discount_percent NUMERIC,
  max_uses INT,
  uses INT DEFAULT 0,
  valid_until TIMESTAMPTZ,
  UNIQUE(event_id, code)
);

-- 7. Waitlist Table
CREATE TABLE IF NOT EXISTS public.waitlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  status TEXT DEFAULT 'waiting',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

-- 8. Refunds Table
CREATE TABLE IF NOT EXISTS public.refunds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE NOT NULL UNIQUE,
  amount NUMERIC NOT NULL,
  reason TEXT,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Reviews Table
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  user_name TEXT NOT NULL DEFAULT 'Attendee',
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

-- 10. Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ticket_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- 11. Allow Public Read Access Policies
CREATE POLICY "Public Read Users" ON public.users FOR SELECT USING (true);
CREATE POLICY "Public Read Events" ON public.events FOR SELECT USING (true);
CREATE POLICY "Public Read Ticket Types" ON public.ticket_types FOR SELECT USING (true);
CREATE POLICY "Public Read Bookings" ON public.bookings FOR SELECT USING (true);
CREATE POLICY "Public Read Reviews" ON public.reviews FOR SELECT USING (true);

-- 12. Insert Demo Events Seed Data
INSERT INTO public.events (id, title, description, venue, city, start_at, end_at, category, status, total_sold, gross_revenue)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Grand Tech & AI Summit 2026', 'Join global tech leaders for 3 days of keynotes and workshops.', 'Convention Center', 'San Francisco', NOW() + INTERVAL '14 days', NOW() + INTERVAL '16 days', 'Technology', 'published', 142, 14180.00),
  ('22222222-2222-2222-2222-222222222222', 'Indie Rock & Jazz Festival', 'An outdoor music festival featuring top indie artists.', 'Central Park Pavilion', 'New York', NOW() + INTERVAL '21 days', NOW() + INTERVAL '22 days', 'Music', 'published', 285, 14250.00),
  ('33333333-3333-3333-3333-333333333333', 'International Food & Wine Expo', 'Exquisite culinary creations and premium wine tasting.', 'Navy Pier Hall', 'Chicago', NOW() + INTERVAL '30 days', NOW() + INTERVAL '31 days', 'Food', 'published', 96, 4800.00)
ON CONFLICT (id) DO NOTHING;
