-- ============================================================================
-- COMPREHENSIVE FIX FOR INFINITE RECURSION ERROR (V2 - Safe Version)
-- ============================================================================
-- This script fixes the "infinite recursion detected in policy for relation 
-- user_roles" error and updates all related policies across your database.
--
-- This version safely handles tables that may not exist yet.
-- Run this ONCE in your Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- PART 1: Create the Security Definer Function
-- ============================================================================
-- This function bypasses RLS to prevent circular dependencies

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

-- ============================================================================
-- PART 2: Fix user_roles Table Policies
-- ============================================================================

-- Enable RLS
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "Users can read own role" ON user_roles;
DROP POLICY IF EXISTS "HR can read all roles" ON user_roles;
DROP POLICY IF EXISTS "Service role can manage roles" ON user_roles;
DROP POLICY IF EXISTS "HR can insert roles" ON user_roles;
DROP POLICY IF EXISTS "HR can update roles" ON user_roles;
DROP POLICY IF EXISTS "HR can delete roles" ON user_roles;

-- Create new policies using the security definer function
CREATE POLICY "Users can read own role" ON user_roles
  FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "HR can read all roles" ON user_roles
  FOR SELECT
  USING (is_hr_user(auth.uid()));

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

-- ============================================================================
-- PART 3: Update Jobs Table Policies (if table exists)
-- ============================================================================

DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'jobs') THEN
    -- Drop existing policies
    DROP POLICY IF EXISTS "HR can insert jobs" ON jobs;
    DROP POLICY IF EXISTS "HR can update jobs" ON jobs;
    DROP POLICY IF EXISTS "HR can delete jobs" ON jobs;

    -- Create new policies
    EXECUTE 'CREATE POLICY "HR can insert jobs" ON jobs FOR INSERT WITH CHECK (is_hr_user(auth.uid()))';
    EXECUTE 'CREATE POLICY "HR can update jobs" ON jobs FOR UPDATE USING (is_hr_user(auth.uid()))';
    EXECUTE 'CREATE POLICY "HR can delete jobs" ON jobs FOR DELETE USING (is_hr_user(auth.uid()))';
    
    RAISE NOTICE '✅ Updated jobs table policies';
  ELSE
    RAISE NOTICE '⚠️  jobs table does not exist - skipping';
  END IF;
END $$;

-- ============================================================================
-- PART 4: Update Internships Table Policies (if table exists)
-- ============================================================================

DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'internships') THEN
    -- Drop existing policies
    DROP POLICY IF EXISTS "HR can insert internships" ON internships;
    DROP POLICY IF EXISTS "HR can update internships" ON internships;
    DROP POLICY IF EXISTS "HR can delete internships" ON internships;

    -- Create new policies
    EXECUTE 'CREATE POLICY "HR can insert internships" ON internships FOR INSERT WITH CHECK (is_hr_user(auth.uid()))';
    EXECUTE 'CREATE POLICY "HR can update internships" ON internships FOR UPDATE USING (is_hr_user(auth.uid()))';
    EXECUTE 'CREATE POLICY "HR can delete internships" ON internships FOR DELETE USING (is_hr_user(auth.uid()))';
    
    RAISE NOTICE '✅ Updated internships table policies';
  ELSE
    RAISE NOTICE '⚠️  internships table does not exist - skipping';
  END IF;
END $$;

-- ============================================================================
-- PART 5: Update Job Applications Table Policies (if table exists)
-- ============================================================================

DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'job_applications') THEN
    -- Drop existing policies
    DROP POLICY IF EXISTS "HR can read job applications" ON job_applications;
    DROP POLICY IF EXISTS "HR can update job applications" ON job_applications;
    DROP POLICY IF EXISTS "HR can delete job applications" ON job_applications;

    -- Create new policies
    EXECUTE 'CREATE POLICY "HR can read job applications" ON job_applications FOR SELECT USING (is_hr_user(auth.uid()))';
    EXECUTE 'CREATE POLICY "HR can update job applications" ON job_applications FOR UPDATE USING (is_hr_user(auth.uid()))';
    EXECUTE 'CREATE POLICY "HR can delete job applications" ON job_applications FOR DELETE USING (is_hr_user(auth.uid()))';
    
    RAISE NOTICE '✅ Updated job_applications table policies';
  ELSE
    RAISE NOTICE '⚠️  job_applications table does not exist - skipping';
  END IF;
END $$;

-- ============================================================================
-- PART 6: Update Internship Applications Table Policies (if table exists)
-- ============================================================================

DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'internship_applications') THEN
    -- Drop existing policies
    DROP POLICY IF EXISTS "HR can read internship applications" ON internship_applications;
    DROP POLICY IF EXISTS "HR can update internship applications" ON internship_applications;
    DROP POLICY IF EXISTS "HR can delete internship applications" ON internship_applications;

    -- Create new policies
    EXECUTE 'CREATE POLICY "HR can read internship applications" ON internship_applications FOR SELECT USING (is_hr_user(auth.uid()))';
    EXECUTE 'CREATE POLICY "HR can update internship applications" ON internship_applications FOR UPDATE USING (is_hr_user(auth.uid()))';
    EXECUTE 'CREATE POLICY "HR can delete internship applications" ON internship_applications FOR DELETE USING (is_hr_user(auth.uid()))';
    
    RAISE NOTICE '✅ Updated internship_applications table policies';
  ELSE
    RAISE NOTICE '⚠️  internship_applications table does not exist - skipping';
  END IF;
END $$;

-- ============================================================================
-- PART 7: Update Employees Table Policies (if table exists)
-- ============================================================================

DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'employees') THEN
    -- Drop existing policies
    DROP POLICY IF EXISTS "HR can select employees" ON employees;
    DROP POLICY IF EXISTS "HR can insert employees" ON employees;
    DROP POLICY IF EXISTS "HR can update employees" ON employees;
    DROP POLICY IF EXISTS "HR can delete employees" ON employees;

    -- Create new policies
    EXECUTE 'CREATE POLICY "HR can select employees" ON employees FOR SELECT USING (is_hr_user(auth.uid()))';
    EXECUTE 'CREATE POLICY "HR can insert employees" ON employees FOR INSERT WITH CHECK (is_hr_user(auth.uid()))';
    EXECUTE 'CREATE POLICY "HR can update employees" ON employees FOR UPDATE USING (is_hr_user(auth.uid())) WITH CHECK (is_hr_user(auth.uid()))';
    EXECUTE 'CREATE POLICY "HR can delete employees" ON employees FOR DELETE USING (is_hr_user(auth.uid()))';
    
    RAISE NOTICE '✅ Updated employees table policies';
  ELSE
    RAISE NOTICE '⚠️  employees table does not exist - skipping';
  END IF;
END $$;

-- ============================================================================
-- PART 8: Grant Necessary Permissions
-- ============================================================================

GRANT SELECT ON user_roles TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

-- ============================================================================
-- PART 9: Add reference_code columns if missing (if tables exist)
-- ============================================================================

DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'jobs') THEN
    ALTER TABLE jobs ADD COLUMN IF NOT EXISTS reference_code TEXT;
    CREATE UNIQUE INDEX IF NOT EXISTS jobs_reference_code_idx 
      ON jobs(reference_code) 
      WHERE reference_code IS NOT NULL;
    RAISE NOTICE '✅ Added reference_code to jobs table';
  END IF;
  
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'internships') THEN
    ALTER TABLE internships ADD COLUMN IF NOT EXISTS reference_code TEXT;
    CREATE UNIQUE INDEX IF NOT EXISTS internships_reference_code_idx 
      ON internships(reference_code) 
      WHERE reference_code IS NOT NULL;
    RAISE NOTICE '✅ Added reference_code to internships table';
  END IF;
END $$;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check that the function was created
SELECT 
  'is_hr_user function exists' as check_name,
  EXISTS (
    SELECT 1 FROM pg_proc 
    WHERE proname = 'is_hr_user'
  ) as result;

-- List all policies on user_roles
SELECT 
  'user_roles policies' as table_name,
  policyname,
  cmd as operation
FROM pg_policies
WHERE tablename = 'user_roles'
ORDER BY policyname;

-- List existing tables
SELECT 
  'Existing tables' as info,
  tablename
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('jobs', 'internships', 'job_applications', 'internship_applications', 'employees', 'user_roles')
ORDER BY tablename;

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================
SELECT '✅ Fix applied successfully! The infinite recursion error should now be resolved.' as status;
