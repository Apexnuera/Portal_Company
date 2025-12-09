-- Complete fix for jobs table issues
-- Run this in your Supabase SQL Editor

-- 1. Add reference_code columns if they don't exist
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS reference_code TEXT;
ALTER TABLE internships ADD COLUMN IF NOT EXISTS reference_code TEXT;

-- 2. Ensure id columns have proper defaults (in case they were lost)
ALTER TABLE jobs ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE internships ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE job_applications ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE internship_applications ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- 3. Create unique indexes for reference codes
CREATE UNIQUE INDEX IF NOT EXISTS jobs_reference_code_idx ON jobs(reference_code) WHERE reference_code IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS internships_reference_code_idx ON internships(reference_code) WHERE reference_code IS NOT NULL;

-- 4. Fix RLS policy for user_roles table to prevent infinite recursion
-- First, enable RLS if not already enabled
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can read own role" ON user_roles;
DROP POLICY IF EXISTS "HR can read all roles" ON user_roles;
DROP POLICY IF EXISTS "Service role can manage roles" ON user_roles;
DROP POLICY IF EXISTS "HR can insert roles" ON user_roles;
DROP POLICY IF EXISTS "HR can update roles" ON user_roles;
DROP POLICY IF EXISTS "HR can delete roles" ON user_roles;

-- Create a security definer function to check if a user is HR
-- This function runs with elevated privileges and bypasses RLS to prevent recursion
CREATE OR REPLACE FUNCTION is_hr_user(user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_roles
    WHERE id = user_id AND role = 'hr'
  );
END;
$$;

-- Allow users to read their own role (no recursion here)
CREATE POLICY "Users can read own role" ON user_roles
  FOR SELECT
  USING (auth.uid() = id);

-- Allow HR to read all roles using the security definer function
CREATE POLICY "HR can read all roles" ON user_roles
  FOR SELECT
  USING (is_hr_user(auth.uid()));

-- Allow HR to insert, update, and delete roles
CREATE POLICY "HR can insert roles" ON user_roles
  FOR INSERT
  WITH CHECK (is_hr_user(auth.uid()));

CREATE POLICY "HR can update roles" ON user_roles
  FOR UPDATE
  USING (is_hr_user(auth.uid()))
  WITH CHECK (is_hr_user(auth.uid()));

CREATE POLICY "HR can delete roles" ON user_roles
  FOR DELETE
  USING (is_hr_user(auth.uid()));

-- 5. Grant necessary permissions
GRANT SELECT ON user_roles TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

-- Verify the changes
SELECT 
  table_name,
  column_name,
  column_default,
  is_nullable
FROM information_schema.columns
WHERE table_name IN ('jobs', 'internships', 'job_applications', 'internship_applications')
  AND column_name = 'id'
ORDER BY table_name;
