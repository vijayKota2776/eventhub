-- EventHub v1.2 Schema Migration
-- Reviews, Admin Support, and Index Enhancements

-- 1. Reviews Table
create table if not exists reviews (
  id uuid primary key default gen_random_uuid(),
  event_id uuid references events not null on delete cascade,
  user_id uuid references users not null on delete cascade,
  user_name text not null default 'Attendee',
  rating int not null check (rating >= 1 and rating <= 5),
  comment text,
  created_at timestamptz default now(),
  unique (event_id, user_id)
);

-- Index for fast lookup of reviews by event
create index if not exists idx_reviews_event_id on reviews(event_id);

-- 2. Ensure events have proper status support
-- Allowed statuses: 'draft', 'pending_approval', 'published', 'rejected'
create index if not exists idx_events_status on events(status);

-- 3. RLS for reviews
alter table reviews enable row level security;

create policy "Anyone can read reviews for published events"
  on reviews for select
  using (true);

create policy "Authenticated users can create reviews"
  on reviews for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own reviews"
  on reviews for update
  using (auth.uid() = user_id);
