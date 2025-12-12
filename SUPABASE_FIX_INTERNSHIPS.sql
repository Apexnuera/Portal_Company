-- Add contract_type column to internships table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'internships' AND column_name = 'contract_type') THEN
        ALTER TABLE internships ADD COLUMN contract_type TEXT NOT NULL DEFAULT 'Internship';
    END IF;
END $$;

-- Add location column to internships table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'internships' AND column_name = 'location') THEN
        ALTER TABLE internships ADD COLUMN location TEXT NOT NULL DEFAULT 'Remote';
    END IF;
END $$;

-- Reload schema cache to ensure the new columns are visible to PostgREST
NOTIFY pgrst, 'reload schema';
