// Supabase Edge Function: send-booking-email
// Deploy with: supabase functions deploy send-booking-email
// Set secret: supabase secrets set RESEND_API_KEY=re_xxxx

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

Deno.serve(async (req) => {
  try {
    const payload = await req.json();

    // This function is triggered by a DB webhook on bookings table
    // Payload shape: { type: 'UPDATE', record: {...booking...}, old_record: {...} }
    if (payload.type !== "UPDATE") return new Response("ok", { status: 200 });
    if (payload.record.status !== "confirmed") return new Response("ok", { status: 200 });

    const booking = payload.record;

    // Fetch related data
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const { data: event } = await supabase
      .from("events")
      .select("title, venue, city, start_at")
      .eq("id", booking.event_id)
      .single();

    const { data: user } = await supabase
      .from("users")
      .select("name, email")
      .eq("id", booking.user_id)
      .single();

    if (!event || !user) return new Response("missing data", { status: 400 });

    const eventDate = new Date(event.start_at).toLocaleString("en-US", {
      weekday: "long", year: "numeric", month: "long",
      day: "numeric", hour: "2-digit", minute: "2-digit",
    });

    // Send via Resend
    const emailRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: "EventHub <tickets@eventhub.app>",
        to: [user.email],
        subject: `Your ticket for ${event.title} is confirmed!`,
        html: `
          <div style="font-family:sans-serif;max-width:600px;margin:auto">
            <h1 style="color:#6200ea">🎟 Booking Confirmed!</h1>
            <p>Hi ${user.name},</p>
            <p>Your booking for <strong>${event.title}</strong> is confirmed.</p>
            <table style="width:100%;border-collapse:collapse;margin:24px 0">
              <tr><td style="padding:8px;color:#888">Event</td><td style="padding:8px;font-weight:bold">${event.title}</td></tr>
              <tr><td style="padding:8px;color:#888">Date</td><td style="padding:8px">${eventDate}</td></tr>
              <tr><td style="padding:8px;color:#888">Venue</td><td style="padding:8px">${event.venue}, ${event.city}</td></tr>
              <tr><td style="padding:8px;color:#888">Quantity</td><td style="padding:8px">${booking.quantity}</td></tr>
              <tr><td style="padding:8px;color:#888">Total Paid</td><td style="padding:8px;font-weight:bold">$${booking.total_amount}</td></tr>
              <tr><td style="padding:8px;color:#888">Booking ID</td><td style="padding:8px;font-family:monospace">${booking.id}</td></tr>
            </table>
            <p>Open the <strong>EventHub app</strong> and go to <em>My Tickets</em> to view your QR code.</p>
            <p style="color:#888;font-size:12px">If you have questions, contact the event organizer through the app.</p>
          </div>
        `,
      }),
    });

    if (!emailRes.ok) {
      const err = await emailRes.text();
      console.error("Resend error:", err);
      return new Response("email failed", { status: 500 });
    }

    return new Response("email sent", { status: 200 });
  } catch (e) {
    console.error(e);
    return new Response("error", { status: 500 });
  }
});
