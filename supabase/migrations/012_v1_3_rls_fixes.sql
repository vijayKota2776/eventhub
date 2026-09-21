-- EventHub v1.3 Schema Migration
-- Fixes missing RLS policies for Users, Events, and Ticket Types

-- 1. Users RLS Fixes
CREATE POLICY "Users can insert own profile" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

-- 2. Events RLS Fixes
CREATE POLICY "Organizers can insert events" ON public.events FOR INSERT WITH CHECK (auth.uid() = organizer_id);
CREATE POLICY "Organizers can update own events" ON public.events FOR UPDATE USING (auth.uid() = organizer_id);
CREATE POLICY "Organizers can delete own events" ON public.events FOR DELETE USING (auth.uid() = organizer_id);

-- 3. Ticket Types RLS Fixes
CREATE POLICY "Organizers can insert ticket types" ON public.ticket_types FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.events WHERE events.id = event_id AND events.organizer_id = auth.uid())
);
CREATE POLICY "Organizers can update ticket types" ON public.ticket_types FOR UPDATE USING (
  EXISTS (SELECT 1 FROM public.events WHERE events.id = event_id AND events.organizer_id = auth.uid())
);
CREATE POLICY "Organizers can delete ticket types" ON public.ticket_types FOR DELETE USING (
  EXISTS (SELECT 1 FROM public.events WHERE events.id = event_id AND events.organizer_id = auth.uid())
);
