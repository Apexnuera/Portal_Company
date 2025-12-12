-- COMPLETE FIX FOR JOBS/INTERNSHIPS SECTION
-- This script fixes all issues with job and internship applications
-- Run this in your Supabase SQL Editor

-- =====================================================
-- PART 1: Fix the is_hr_user function
-- The function was referencing wrong column name
-- =====================================================

CREATE OR REPLACE FUNCTION is_hr_user(check_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_roles 
    WHERE user_roles.id = check_user_id 
    AND user_roles.role = 'hr'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- PART 2: Ensure tables exist with correct schema
-- =====================================================

-- Jobs Table
CREATE TABLE IF NOT EXISTS jobs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  location TEXT NOT NULL DEFAULT 'Remote',
  contract_type TEXT NOT NULL DEFAULT 'Full-Time',
  department TEXT NOT NULL DEFAULT 'General',
  posting_date DATE NOT NULL DEFAULT CURRENT_DATE,
  application_deadline DATE NOT NULL DEFAULT (CURRENT_DATE + INTERVAL '30 days'),
  experience TEXT NOT NULL DEFAULT 'Entry Level',
  skills TEXT[] NOT NULL DEFAULT '{}',
  responsibilities TEXT[] NOT NULL DEFAULT '{}',
  qualifications TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Internships Table
CREATE TABLE IF NOT EXISTS internships (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  skill TEXT NOT NULL,
  qualification TEXT NOT NULL,
  duration TEXT NOT NULL,
  description TEXT NOT NULL,
  location TEXT NOT NULL DEFAULT 'Remote',
  contract_type TEXT NOT NULL DEFAULT 'Internship',
  posting_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Add missing columns to internships if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'internships' AND column_name = 'location') THEN
        ALTER TABLE internships ADD COLUMN location TEXT NOT NULL DEFAULT 'Remote';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'internships' AND column_name = 'contract_type') THEN
        ALTER TABLE internships ADD COLUMN contract_type TEXT NOT NULL DEFAULT 'Internship';
    END IF;
END $$;

-- Job Applications Table
CREATE TABLE IF NOT EXISTS job_applications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  resume_name TEXT NOT NULL,
  resume_data TEXT,
  status TEXT DEFAULT 'In Progress',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Internship Applications Table
CREATE TABLE IF NOT EXISTS internship_applications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  internship_id UUID REFERENCES internships(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  resume_name TEXT NOT NULL,
  resume_data TEXT,
  status TEXT DEFAULT 'In Progress',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- PART 3: Enable RLS on all tables
-- =====================================================

ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE internships ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE internship_applications ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- PART 4: Drop all existing policies to start fresh
-- =====================================================

-- Jobs policies
DROP POLICY IF EXISTS "Public read access for jobs" ON jobs;
DROP POLICY IF EXISTS "HR can insert jobs" ON jobs;
DROP POLICY IF EXISTS "HR can update jobs" ON jobs;
DROP POLICY IF EXISTS "HR can delete jobs" ON jobs;

-- Internships policies
DROP POLICY IF EXISTS "Public read access for internships" ON internships;
DROP POLICY IF EXISTS "HR can insert internships" ON internships;
DROP POLICY IF EXISTS "HR can update internships" ON internships;
DROP POLICY IF EXISTS "HR can delete internships" ON internships;

-- Job Applications policies
DROP POLICY IF EXISTS "Public insert access for job applications" ON job_applications;
DROP POLICY IF EXISTS "Anyone can insert job applications" ON job_applications;
DROP POLICY IF EXISTS "HR can read job applications" ON job_applications;
DROP POLICY IF EXISTS "Applicant can read own job application" ON job_applications;
DROP POLICY IF EXISTS "HR can update job applications" ON job_applications;
DROP POLICY IF EXISTS "HR can delete job applications" ON job_applications;

-- Internship Applications policies
DROP POLICY IF EXISTS "Public insert access for internship applications" ON internship_applications;
DROP POLICY IF EXISTS "Anyone can insert internship applications" ON internship_applications;
DROP POLICY IF EXISTS "HR can read internship applications" ON internship_applications;
DROP POLICY IF EXISTS "Applicant can read own internship application" ON internship_applications;
DROP POLICY IF EXISTS "HR can update internship applications" ON internship_applications;
DROP POLICY IF EXISTS "HR can delete internship applications" ON internship_applications;

-- =====================================================
-- PART 5: Create new policies for Jobs
-- =====================================================

-- Anyone can view jobs (public listing)
CREATE POLICY "Public read access for jobs" ON jobs 
FOR SELECT USING (true);

-- Only HR can create jobs
CREATE POLICY "HR can insert jobs" ON jobs 
FOR INSERT WITH CHECK (is_hr_user(auth.uid()));

-- Only HR can update jobs
CREATE POLICY "HR can update jobs" ON jobs 
FOR UPDATE USING (is_hr_user(auth.uid()));

-- Only HR can delete jobs
CREATE POLICY "HR can delete jobs" ON jobs 
FOR DELETE USING (is_hr_user(auth.uid()));

-- =====================================================
-- PART 6: Create new policies for Internships
-- =====================================================

-- Anyone can view internships (public listing)
CREATE POLICY "Public read access for internships" ON internships 
FOR SELECT USING (true);

-- Only HR can create internships
CREATE POLICY "HR can insert internships" ON internships 
FOR INSERT WITH CHECK (is_hr_user(auth.uid()));

-- Only HR can update internships
CREATE POLICY "HR can update internships" ON internships 
FOR UPDATE USING (is_hr_user(auth.uid()));

-- Only HR can delete internships
CREATE POLICY "HR can delete internships" ON internships 
FOR DELETE USING (is_hr_user(auth.uid()));

-- =====================================================
-- PART 7: Create new policies for Job Applications
-- IMPORTANT: Allow ANYONE (even anonymous) to apply
-- =====================================================

-- Anyone can submit a job application
CREATE POLICY "Anyone can insert job applications" ON job_applications 
FOR INSERT WITH CHECK (true);

-- HR can read all job applications
CREATE POLICY "HR can read job applications" ON job_applications 
FOR SELECT USING (is_hr_user(auth.uid()));

-- Applicants can read their own applications (using JWT email)
CREATE POLICY "Applicant can read own job application" ON job_applications 
FOR SELECT USING (
  email = coalesce(auth.jwt() ->> 'email', '')
);

-- HR can update application status
CREATE POLICY "HR can update job applications" ON job_applications 
FOR UPDATE USING (is_hr_user(auth.uid()));

-- HR can delete applications
CREATE POLICY "HR can delete job applications" ON job_applications 
FOR DELETE USING (is_hr_user(auth.uid()));

-- =====================================================
-- PART 8: Create new policies for Internship Applications
-- IMPORTANT: Allow ANYONE (even anonymous) to apply
-- =====================================================

-- Anyone can submit an internship application
CREATE POLICY "Anyone can insert internship applications" ON internship_applications 
FOR INSERT WITH CHECK (true);

-- HR can read all internship applications
CREATE POLICY "HR can read internship applications" ON internship_applications 
FOR SELECT USING (is_hr_user(auth.uid()));

-- Applicants can read their own applications (using JWT email)
CREATE POLICY "Applicant can read own internship application" ON internship_applications 
FOR SELECT USING (
  email = coalesce(auth.jwt() ->> 'email', '')
);

-- HR can update application status
CREATE POLICY "HR can update internship applications" ON internship_applications 
FOR UPDATE USING (is_hr_user(auth.uid()));

-- HR can delete applications
CREATE POLICY "HR can delete internship applications" ON internship_applications 
FOR DELETE USING (is_hr_user(auth.uid()));

-- =====================================================
-- PART 9: Grant necessary permissions
-- =====================================================

-- Allow anonymous users to insert applications
GRANT INSERT ON job_applications TO anon;
GRANT INSERT ON internship_applications TO anon;

-- Allow authenticated users full access to applications tables
GRANT ALL ON job_applications TO authenticated;
GRANT ALL ON internship_applications TO authenticated;

-- Allow reading of jobs and internships to everyone
GRANT SELECT ON jobs TO anon;
GRANT SELECT ON internships TO anon;
GRANT ALL ON jobs TO authenticated;
GRANT ALL ON internships TO authenticated;

-- =====================================================
-- PART 10: Create indexes for better performance
-- =====================================================

CREATE INDEX IF NOT EXISTS jobs_created_at_idx ON jobs(created_at DESC);
CREATE INDEX IF NOT EXISTS internships_created_at_idx ON internships(created_at DESC);
CREATE INDEX IF NOT EXISTS job_applications_job_id_idx ON job_applications(job_id);
CREATE INDEX IF NOT EXISTS job_applications_created_at_idx ON job_applications(created_at DESC);
CREATE INDEX IF NOT EXISTS internship_applications_internship_id_idx ON internship_applications(internship_id);
CREATE INDEX IF NOT EXISTS internship_applications_created_at_idx ON internship_applications(created_at DESC);

-- Reload schema cache
NOTIFY pgrst, 'reload schema';
