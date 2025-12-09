-- Add reference_code columns to existing tables
-- Run this AFTER running the main supabase_jobs_schema.sql

ALTER TABLE jobs ADD COLUMN IF NOT EXISTS reference_code TEXT;
ALTER TABLE internships ADD COLUMN IF NOT EXISTS reference_code TEXT;

-- Create unique indexes to prevent duplicate reference codes
CREATE UNIQUE INDEX IF NOT EXISTS jobs_reference_code_idx ON jobs(reference_code) WHERE reference_code IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS internships_reference_code_idx ON internships(reference_code) WHERE reference_code IS NOT NULL;
