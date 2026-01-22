-- SQL Schema for Key Dates (Admission Dates)
-- Run this in Supabase SQL Editor

-- Create key_dates table
CREATE TABLE IF NOT EXISTS public.key_dates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    applications_open DATE,
    assessments_start DATE,
    assessments_end DATE,
    decisions DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.key_dates ENABLE ROW LEVEL SECURITY;

-- Policy: Allow public to read key dates
CREATE POLICY "Allow public read access"
ON public.key_dates
FOR SELECT
TO public
USING (true);

-- Policy: Allow authenticated users to insert/update/delete
-- (You can make this more restrictive if needed)
CREATE POLICY "Allow authenticated users to modify"
ON public.key_dates
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Alternative: If you want anyone to be able to modify (less secure, but simpler for your use case)
-- Uncomment these and comment out the authenticated policy above
-- CREATE POLICY "Allow public insert" ON public.key_dates FOR INSERT TO public WITH CHECK (true);
-- CREATE POLICY "Allow public update" ON public.key_dates FOR UPDATE TO public USING (true) WITH CHECK (true);
-- CREATE POLICY "Allow public delete" ON public.key_dates FOR DELETE TO public USING (true);

-- Insert default/placeholder data
INSERT INTO public.key_dates (applications_open, assessments_start, assessments_end, decisions)
VALUES ('2024-10-01', '2024-10-15', '2024-10-30', '2024-11-10')
ON CONFLICT (id) DO NOTHING;

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to call the function
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.key_dates
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- Note: This table is designed to have only ONE row for the current admission cycle.
-- The admin will UPDATE this row rather than creating new ones.

