-- ============================================================
-- FARMAI – Supabase Storage Buckets Setup
-- Run this in your Supabase SQL Editor AFTER the main schema
-- ============================================================

-- ============================================================
-- CREATE STORAGE BUCKETS
-- ============================================================

-- 1. Crop images (disease detection uploads)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'crop-images',
  'crop-images',
  true,
  5242880,  -- 5 MB
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic']
) ON CONFLICT (id) DO NOTHING;

-- 2. Pest images (pest detection uploads)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'pest-images',
  'pest-images',
  true,
  5242880,  -- 5 MB
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic']
) ON CONFLICT (id) DO NOTHING;

-- 3. Profile images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'profile-images',
  'profile-images',
  true,
  2097152,  -- 2 MB
  ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- STORAGE POLICIES – crop-images
-- ============================================================

-- Authenticated users can upload to their own folder
CREATE POLICY "Users upload own crop images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'crop-images'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Anyone authenticated can view crop images (needed for displaying results)
CREATE POLICY "Authenticated can view crop images"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'crop-images');

-- Users can delete their own crop images
CREATE POLICY "Users delete own crop images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'crop-images'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================================
-- STORAGE POLICIES – pest-images
-- ============================================================

CREATE POLICY "Users upload own pest images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'pest-images'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Authenticated can view pest images"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'pest-images');

CREATE POLICY "Users delete own pest images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'pest-images'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================================
-- STORAGE POLICIES – profile-images
-- ============================================================

CREATE POLICY "Users upload own profile image"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile-images'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Anyone can view profile images"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'profile-images');

CREATE POLICY "Users update own profile image"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profile-images'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users delete own profile image"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile-images'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
