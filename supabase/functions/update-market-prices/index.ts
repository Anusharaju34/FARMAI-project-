// supabase/functions/update-market-prices/index.ts
// Schedule with Supabase Cron: every day at 6:00 AM IST
// cron: "30 0 * * *"   (00:30 UTC = 06:00 IST)

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Simulated market price fluctuation (replace with real AGMARKNET / commodity API)
function generatePrice(base: number, volatility: number): number {
  const change = (Math.random() - 0.48) * volatility;
  return Math.max(base * 0.8, base + change);
}

const CROP_BASES: Record<string, { price: number; volatility: number; unit: string; market: string }> = {
  Rice:      { price: 2340, volatility: 80,  unit: "₹/quintal", market: "APMC Mumbai"    },
  Wheat:     { price: 1890, volatility: 60,  unit: "₹/quintal", market: "APMC Delhi"     },
  Maize:     { price: 1780, volatility: 70,  unit: "₹/quintal", market: "APMC Pune"      },
  Cotton:    { price: 6450, volatility: 200, unit: "₹/quintal", market: "Rajkot Market"  },
  Tomato:    { price: 890,  volatility: 150, unit: "₹/quintal", market: "APMC Bangalore" },
  Onion:     { price: 1240, volatility: 120, unit: "₹/quintal", market: "Lasalgaon APMC" },
  Potato:    { price: 980,  volatility: 60,  unit: "₹/quintal", market: "Agra Market"    },
  Soybean:   { price: 4120, volatility: 150, unit: "₹/quintal", market: "Indore APMC"    },
  Groundnut: { price: 5890, volatility: 180, unit: "₹/quintal", market: "Junagadh Market"},
  Sugarcane: { price: 315,  volatility: 5,   unit: "₹/quintal", market: "UP State Price" },
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
  );

  const updates = Object.entries(CROP_BASES).map(([crop, cfg]) => {
    const newPrice  = Math.round(generatePrice(cfg.price, cfg.volatility));
    const predicted = Math.round(generatePrice(newPrice, cfg.volatility * 0.6));
    const change    = parseFloat((((newPrice - cfg.price) / cfg.price) * 100).toFixed(2));
    return {
      crop_name:       crop,
      current_price:   newPrice,
      predicted_price: predicted,
      price_unit:      cfg.unit,
      market:          cfg.market,
      change_percent:  change,
      trend:           change > 0.5 ? "up" : change < -0.5 ? "down" : "stable",
      updated_at:      new Date().toISOString(),
    };
  });

  const { error } = await supabase
    .from("market_predictions")
    .upsert(updates, { onConflict: "crop_name" });

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }

  return new Response(
    JSON.stringify({ success: true, updated: updates.length }),
    { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
  );
});
