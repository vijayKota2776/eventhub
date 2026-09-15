-- Promo Codes
create table promo_codes(
  id uuid primary key default gen_random_uuid(),
  event_id uuid references events not null,
  code text not null,
  discount_amount numeric,
  discount_percent numeric,
  max_uses int,
  uses int default 0,
  valid_until timestamptz,
  unique (event_id, code)
);

-- Waitlist
create table waitlist(
  id uuid primary key default gen_random_uuid(),
  event_id uuid references events not null,
  user_id uuid references users not null,
  status text default 'waiting', -- waiting|notified|expired
  created_at timestamptz default now(),
  unique (event_id, user_id)
);

-- Refunds
create table refunds(
  id uuid primary key default gen_random_uuid(),
  booking_id uuid references bookings not null unique,
  amount numeric not null,
  reason text,
  status text default 'pending', -- pending|approved|rejected
  created_at timestamptz default now()
);

-- Update RPC to support promo codes
create or replace function book_ticket(
  p_ticket_type_id uuid,
  p_qty            int,
  p_user_id        uuid,
  p_idem           text,
  p_promo_code     text default null
) returns uuid
language plpgsql security definer as $$
declare
  v_remaining int;
  v_price     numeric;
  v_booking   uuid;
  v_event_id  uuid;
  v_promo_id  uuid;
  v_promo_pct numeric;
  v_promo_amt numeric;
begin
  select id into v_booking from bookings where idempotency_key = p_idem;
  if found then return v_booking; end if;

  select quantity_total - quantity_sold, price, event_id
    into v_remaining, v_price, v_event_id
  from ticket_types
  where id = p_ticket_type_id
  for update;

  if v_remaining < p_qty then
    raise exception 'SOLD_OUT' using errcode = 'P0001';
  end if;

  -- Validate and apply promo code
  if p_promo_code is not null then
    select id, discount_percent, discount_amount
      into v_promo_id, v_promo_pct, v_promo_amt
    from promo_codes
    where event_id = v_event_id 
      and code = p_promo_code 
      and (valid_until is null or valid_until > now())
      and (max_uses is null or uses < max_uses)
    for update;

    if v_promo_id is null then
      raise exception 'INVALID_PROMO' using errcode = 'P0002';
    end if;

    if v_promo_pct is not null then
      v_price := v_price - (v_price * (v_promo_pct / 100.0));
    elsif v_promo_amt is not null then
      v_price := v_price - v_promo_amt;
    end if;
    if v_price < 0 then v_price := 0; end if;

    update promo_codes set uses = uses + 1 where id = v_promo_id;
  end if;

  update ticket_types
     set quantity_sold = quantity_sold + p_qty
   where id = p_ticket_type_id;

  insert into bookings (user_id, event_id, ticket_type_id, quantity, unit_price,
                        total_amount, status, idempotency_key, qr_token)
  values (p_user_id, v_event_id, p_ticket_type_id, p_qty, v_price, v_price * p_qty,
          'pending_payment', p_idem, encode(gen_random_bytes(24), 'hex'))
  returning id into v_booking;

  return v_booking;
end $$;
