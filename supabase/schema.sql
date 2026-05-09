-- ============================================================
-- PhishEye – Supabase Database Setup
-- Run this SQL in your Supabase project's SQL Editor
-- ============================================================

-- 1. Create scans table
CREATE TABLE IF NOT EXISTS public.scans (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  input       TEXT NOT NULL,
  type        TEXT NOT NULL CHECK (type IN ('url', 'email')),
  risk_score  INTEGER NOT NULL CHECK (risk_score >= 0 AND risk_score <= 100),
  result      TEXT NOT NULL,   -- JSON string with flags, verdict, summary
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Index for fast per-user queries
CREATE INDEX IF NOT EXISTS idx_scans_user_id
  ON public.scans (user_id, created_at DESC);

-- 3. Enable Row Level Security
ALTER TABLE public.scans ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies – users can only access their own scans

-- SELECT: read own scans
CREATE POLICY "Users can view own scans"
  ON public.scans
  FOR SELECT
  USING (auth.uid() = user_id);

-- INSERT: only insert with own user_id
CREATE POLICY "Users can insert own scans"
  ON public.scans
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- DELETE: only delete own scans
CREATE POLICY "Users can delete own scans"
  ON public.scans
  FOR DELETE
  USING (auth.uid() = user_id);

-- 5. (Optional) Grant usage to anon and authenticated roles
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT, DELETE ON public.scans TO authenticated;
