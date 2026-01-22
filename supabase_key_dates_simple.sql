-- Simple Key Dates Table Setup (with public access)
-- Run this in Supabase SQL Editor

-- Drop table if it exists (to start fresh)
DROP TABLE IF EXISTS public.key_dates CASCADE;

-- Create key_dates table
CREATE TABLE public.key_dates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    applications_open DATE,
    assessments_start DATE,
    assessments_end DATE,
    decisions DATE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.key_dates ENABLE ROW LEVEL SECURITY;

-- Allow EVERYONE to read, insert, update, delete (for testing)
CREATE POLICY "Allow all access to key_dates"
ON public.key_dates
FOR ALL
TO public
USING (true)
WITH CHECK (true);

-- Insert a default row so we always have one record to UPDATE
INSERT INTO public.key_dates (applications_open, assessments_start, assessments_end, decisions)
VALUES ('2026-10-01', '2026-10-15', '2026-10-30', '2026-11-10');

-- Show the data
SELECT * FROM public.key_dates;

