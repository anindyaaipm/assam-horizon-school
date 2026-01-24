-- Add image_url column to notices table
-- Run this in Supabase SQL Editor

-- Add image_url column to notices table
ALTER TABLE public.notices
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Add comment to describe the column
COMMENT ON COLUMN public.notices.image_url IS 'Optional image URL for visual notices';

-- Verify the change
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'notices'
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Note: Existing notices will have NULL for image_url, which is fine
-- The UI will handle NULL values and only show images when they exist
