-- ============================================================
-- FARMAI – Supabase Database Schema
-- Run this SQL in your Supabase SQL Editor
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- USERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.users (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email         TEXT NOT NULL,
  full_name     TEXT NOT NULL DEFAULT '',
  phone         TEXT,
  profile_image_url TEXT,
  location      TEXT,
  farm_size     TEXT,
  primary_crops TEXT[],
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index on email for fast lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- RLS: Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================================
-- DISEASE PREDICTIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.disease_predictions (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id             UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  image_url           TEXT NOT NULL,
  crop_type           TEXT NOT NULL,
  disease_name        TEXT NOT NULL,
  confidence_score    DECIMAL(4,3) NOT NULL CHECK (confidence_score BETWEEN 0 AND 1),
  severity            TEXT NOT NULL CHECK (severity IN ('Low', 'Moderate', 'Severe')),
  treatment_suggestions TEXT[] NOT NULL DEFAULT '{}',
  description         TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_disease_user_id ON public.disease_predictions(user_id);
CREATE INDEX IF NOT EXISTS idx_disease_created_at ON public.disease_predictions(created_at DESC);

ALTER TABLE public.disease_predictions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own disease predictions"
  ON public.disease_predictions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own disease predictions"
  ON public.disease_predictions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- PEST DETECTIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.pest_detections (
  id                        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id                   UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  image_url                 TEXT NOT NULL,
  pest_name                 TEXT NOT NULL,
  confidence_score          DECIMAL(4,3) NOT NULL CHECK (confidence_score BETWEEN 0 AND 1),
  severity_level            TEXT NOT NULL CHECK (severity_level IN ('Low', 'Medium', 'High', 'Critical')),
  prevention_recommendations TEXT[] NOT NULL DEFAULT '{}',
  description               TEXT,
  economic_threshold        TEXT,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pest_user_id ON public.pest_detections(user_id);
CREATE INDEX IF NOT EXISTS idx_pest_created_at ON public.pest_detections(created_at DESC);

ALTER TABLE public.pest_detections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own pest detections"
  ON public.pest_detections FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own pest detections"
  ON public.pest_detections FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- WEATHER ALERTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.weather_alerts (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  location    TEXT NOT NULL,
  alert_type  TEXT NOT NULL,
  severity    TEXT NOT NULL CHECK (severity IN ('Low', 'Moderate', 'High', 'Extreme')),
  title       TEXT NOT NULL,
  description TEXT NOT NULL,
  valid_from  TIMESTAMPTZ NOT NULL,
  valid_until TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_weather_location ON public.weather_alerts(location);
CREATE INDEX IF NOT EXISTS idx_weather_valid ON public.weather_alerts(valid_from, valid_until);

ALTER TABLE public.weather_alerts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view weather alerts"
  ON public.weather_alerts FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================
-- MARKET PREDICTIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.market_predictions (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  crop_name       TEXT NOT NULL,
  current_price   DECIMAL(10,2) NOT NULL,
  predicted_price DECIMAL(10,2) NOT NULL,
  price_unit      TEXT NOT NULL DEFAULT '₹/quintal',
  market          TEXT NOT NULL DEFAULT 'APMC',
  change_percent  DECIMAL(6,2) NOT NULL DEFAULT 0,
  trend           TEXT NOT NULL CHECK (trend IN ('up', 'down', 'stable')),
  advice          TEXT,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_market_crop_name ON public.market_predictions(crop_name);
CREATE INDEX IF NOT EXISTS idx_market_updated ON public.market_predictions(updated_at DESC);

ALTER TABLE public.market_predictions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view market prices"
  ON public.market_predictions FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================
-- IRRIGATION RECORDS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.irrigation_records (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  crop_type         TEXT NOT NULL,
  soil_type         TEXT NOT NULL,
  farm_area         DECIMAL(6,2) DEFAULT 1.0,
  water_required    DECIMAL(8,2) NOT NULL,
  schedule          TEXT NOT NULL,
  recommendations   TEXT[] NOT NULL DEFAULT '{}',
  method            TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_irrigation_user_id ON public.irrigation_records(user_id);

ALTER TABLE public.irrigation_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own irrigation records"
  ON public.irrigation_records FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- FORUM POSTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.forum_posts (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  user_full_name  TEXT NOT NULL DEFAULT 'Farmer',
  user_image_url  TEXT,
  title           TEXT NOT NULL,
  content         TEXT NOT NULL,
  image_url       TEXT,
  likes_count     INTEGER NOT NULL DEFAULT 0,
  comments_count  INTEGER NOT NULL DEFAULT 0,
  tags            TEXT[] DEFAULT '{}',
  is_pinned       BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_forum_posts_created ON public.forum_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_forum_posts_user ON public.forum_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_forum_posts_tags ON public.forum_posts USING GIN(tags);

ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view forum posts"
  ON public.forum_posts FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can create forum posts"
  ON public.forum_posts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts"
  ON public.forum_posts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts"
  ON public.forum_posts FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- FORUM POST LIKES TABLE (for tracking individual likes)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.forum_post_likes (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id    UUID NOT NULL REFERENCES public.forum_posts(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_likes_post ON public.forum_post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_likes_user ON public.forum_post_likes(user_id);

ALTER TABLE public.forum_post_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own likes"
  ON public.forum_post_likes FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Toggle like stored procedure
CREATE OR REPLACE FUNCTION toggle_post_like(post_id UUID, user_id UUID)
RETURNS void AS $$
DECLARE
  existing_like UUID;
BEGIN
  SELECT id INTO existing_like
  FROM public.forum_post_likes
  WHERE forum_post_likes.post_id = toggle_post_like.post_id
    AND forum_post_likes.user_id = toggle_post_like.user_id;

  IF existing_like IS NOT NULL THEN
    DELETE FROM public.forum_post_likes WHERE id = existing_like;
    UPDATE public.forum_posts SET likes_count = likes_count - 1 WHERE id = post_id;
  ELSE
    INSERT INTO public.forum_post_likes (post_id, user_id)
    VALUES (toggle_post_like.post_id, toggle_post_like.user_id);
    UPDATE public.forum_posts SET likes_count = likes_count + 1 WHERE id = post_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FORUM COMMENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.forum_comments (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id        UUID NOT NULL REFERENCES public.forum_posts(id) ON DELETE CASCADE,
  user_id        UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  user_full_name TEXT NOT NULL DEFAULT 'Farmer',
  content        TEXT NOT NULL,
  likes_count    INTEGER NOT NULL DEFAULT 0,
  parent_id      UUID REFERENCES public.forum_comments(id) ON DELETE CASCADE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_comments_post_id ON public.forum_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON public.forum_comments(user_id);

ALTER TABLE public.forum_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view comments"
  ON public.forum_comments FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can create comments"
  ON public.forum_comments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments"
  ON public.forum_comments FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger to update comment count
CREATE OR REPLACE FUNCTION update_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.forum_posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.forum_posts SET comments_count = GREATEST(comments_count - 1, 0) WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_comments_count
AFTER INSERT OR DELETE ON public.forum_comments
FOR EACH ROW EXECUTE FUNCTION update_comments_count();

-- ============================================================
-- EXPERT QUERIES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.expert_queries (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  subject       TEXT NOT NULL,
  question      TEXT NOT NULL,
  category      TEXT NOT NULL DEFAULT 'General',
  status        TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'in_review', 'answered', 'closed')),
  priority      TEXT NOT NULL DEFAULT 'normal'
                  CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  expert_reply  TEXT,
  expert_id     UUID REFERENCES public.users(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  replied_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_expert_user_id ON public.expert_queries(user_id);
CREATE INDEX IF NOT EXISTS idx_expert_status ON public.expert_queries(status);
CREATE INDEX IF NOT EXISTS idx_expert_created ON public.expert_queries(created_at DESC);

ALTER TABLE public.expert_queries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own expert queries"
  ON public.expert_queries FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can submit expert queries"
  ON public.expert_queries FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- NOTIFICATIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title      TEXT NOT NULL,
  body       TEXT NOT NULL,
  type       TEXT NOT NULL DEFAULT 'system'
               CHECK (type IN ('disease', 'pest', 'weather', 'market', 'irrigation', 'expert', 'forum', 'system')),
  is_read    BOOLEAN NOT NULL DEFAULT FALSE,
  action_url TEXT,
  metadata   JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notif_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notif_is_read ON public.notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_notif_created ON public.notifications(created_at DESC);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- Allow server-side inserts via service role (for push notifications)
CREATE POLICY "Service role can insert notifications"
  ON public.notifications FOR INSERT
  TO service_role
  WITH CHECK (true);

-- ============================================================
-- REALTIME: Enable for live notifications
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.forum_posts;
ALTER PUBLICATION supabase_realtime ADD TABLE public.expert_queries;

-- ============================================================
-- SEED: Sample market data
-- ============================================================
INSERT INTO public.market_predictions (crop_name, current_price, predicted_price, price_unit, market, change_percent, trend, advice)
VALUES
  ('Rice',      2340, 2480, '₹/quintal', 'APMC Mumbai',    2.3,  'up',     'Good time to sell. Export demand strong.'),
  ('Wheat',     1890, 1820, '₹/quintal', 'APMC Delhi',    -0.8,  'down',   'Hold stock. Post-harvest supply pressure.'),
  ('Maize',     1780, 1850, '₹/quintal', 'APMC Pune',      1.2,  'up',     'Poultry feed demand driving prices up.'),
  ('Cotton',    6450, 6700, '₹/quintal', 'Rajkot Market',  1.8,  'up',     'Mill demand strong. Good selling opportunity.'),
  ('Tomato',     890, 1100, '₹/quintal', 'APMC Bangalore', 5.1,  'up',     'Short supply – excellent selling opportunity.'),
  ('Onion',     1240, 1050, '₹/quintal', 'Lasalgaon APMC',-3.2,  'down',   'Prices declining. Sell current stock soon.'),
  ('Potato',     980, 1050, '₹/quintal', 'Agra Market',    0.5,  'stable', 'Cold storage demand keeping prices stable.'),
  ('Soybean',   4120, 4350, '₹/quintal', 'Indore APMC',    3.4,  'up',     'Oilmeal exports boosting demand.'),
  ('Groundnut', 5890, 6100, '₹/quintal', 'Junagadh Market', 2.1, 'up',     'Oil demand strong. Favorable for sellers.'),
  ('Sugarcane',  315,  320, '₹/quintal', 'UP State Price', 0.3,  'stable', 'Government SAP provides price stability.')
ON CONFLICT DO NOTHING;
