// supabase/functions/notify-farmer/index.ts
// Deploy with: supabase functions deploy notify-farmer

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface NotifyPayload {
  user_id: string;
  title: string;
  body: string;
  type: "disease" | "pest" | "weather" | "market" | "irrigation" | "expert" | "forum" | "system";
  action_url?: string;
  metadata?: Record<string, unknown>;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const payload: NotifyPayload = await req.json();

    // Insert notification into DB (triggers Realtime to the Flutter app)
    const { error } = await supabase.from("notifications").insert({
      user_id:    payload.user_id,
      title:      payload.title,
      body:       payload.body,
      type:       payload.type,
      action_url: payload.action_url ?? null,
      metadata:   payload.metadata ?? {},
      is_read:    false,
    });

    if (error) throw error;

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});
