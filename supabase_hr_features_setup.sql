-- ============================================================================
-- SUPABASE HR FEATURES SETUP - Jobs, Internships, and Employees
-- ============================================================================
-- This script creates tables for HR to manage jobs, internships, and employees
-- Run this in your Supabase SQL Editor after running supabase_complete_setup.sql
-- ============================================================================

-- ============================================================================
-- 1. JOBS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS jobs (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  location TEXT NOT NULL,
  contract_type TEXT NOT NULL,
  department TEXT NOT NULL,
  posting_date TEXT NOT NULL,
  application_deadline TEXT NOT NULL,
  experience TEXT NOT NULL,
  skills TEXT[] NOT NULL DEFAULT '{}',
  responsibilities TEXT[] NOT NULL DEFAULT '{}',
  qualifications TEXT[] NOT NULL DEFAULT '{}',
  description TEXT NOT NULL,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can view jobs" ON jobs;
DROP POLICY IF EXISTS "HR can create jobs" ON jobs;
DROP POLICY IF EXISTS "HR can update jobs" ON jobs;
DROP POLICY IF EXISTS "HR can delete jobs" ON jobs;

-- Policy: Anyone can view jobs (public access)
CREATE POLICY "Anyone can view jobs"
  ON jobs
  FOR SELECT
  USING (true);

-- Policy: HR can create jobs
CREATE POLICY "HR can create jobs"
  ON jobs
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Policy: HR can update jobs
CREATE POLICY "HR can update jobs"
  ON jobs
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Policy: HR can delete jobs
CREATE POLICY "HR can delete jobs"
  ON jobs
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Create indexes
CREATE INDEX IF NOT EXISTS jobs_created_at_idx ON jobs(created_at DESC);
CREATE INDEX IF NOT EXISTS jobs_title_idx ON jobs(title);
CREATE INDEX IF NOT EXISTS jobs_department_idx ON jobs(department);

-- ============================================================================
-- 2. INTERNSHIPS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS internships (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  duration TEXT NOT NULL,
  skill TEXT NOT NULL,
  qualification TEXT NOT NULL,
  description TEXT NOT NULL,
  posting_date TEXT NOT NULL,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE internships ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can view internships" ON internships;
DROP POLICY IF EXISTS "HR can create internships" ON internships;
DROP POLICY IF EXISTS "HR can update internships" ON internships;
DROP POLICY IF EXISTS "HR can delete internships" ON internships;

-- Policy: Anyone can view internships (public access)
CREATE POLICY "Anyone can view internships"
  ON internships
  FOR SELECT
  USING (true);

-- Policy: HR can create internships
CREATE POLICY "HR can create internships"
  ON internships
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Policy: HR can update internships
CREATE POLICY "HR can update internships"
  ON internships
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Policy: HR can delete internships
CREATE POLICY "HR can delete internships"
  ON internships
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Create indexes
CREATE INDEX IF NOT EXISTS internships_created_at_idx ON internships(created_at DESC);
CREATE INDEX IF NOT EXISTS internships_title_idx ON internships(title);

-- ============================================================================
-- 3. JOB APPLICATIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS job_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id TEXT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  resume_name TEXT NOT NULL,
  resume_data TEXT, -- Base64 encoded or URL
  status TEXT NOT NULL DEFAULT 'In Progress' CHECK (status IN ('In Progress', 'Selected', 'Rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(job_id, email)
);

-- Enable Row Level Security
ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "HR can view all job applications" ON job_applications;
DROP POLICY IF EXISTS "Anyone can create job applications" ON job_applications;
DROP POLICY IF EXISTS "HR can update job applications" ON job_applications;
DROP POLICY IF EXISTS "HR can delete job applications" ON job_applications;

-- Policy: HR can view all job applications
CREATE POLICY "HR can view all job applications"
  ON job_applications
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Policy: Anyone can create job applications
CREATE POLICY "Anyone can create job applications"
  ON job_applications
  FOR INSERT
  WITH CHECK (true);

-- Policy: HR can update job applications
CREATE POLICY "HR can update job applications"
  ON job_applications
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Policy: HR can delete job applications
CREATE POLICY "HR can delete job applications"
  ON job_applications
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Create indexes
CREATE INDEX IF NOT EXISTS job_applications_job_id_idx ON job_applications(job_id);
CREATE INDEX IF NOT EXISTS job_applications_email_idx ON job_applications(email);
CREATE INDEX IF NOT EXISTS job_applications_status_idx ON job_applications(status);

-- ============================================================================
-- 4. INTERNSHIP APPLICATIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS internship_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  internship_id TEXT NOT NULL REFERENCES internships(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  resume_name TEXT NOT NULL,
  resume_data TEXT, -- Base64 encoded or URL
  status TEXT NOT NULL DEFAULT 'In Progress' CHECK (status IN ('In Progress', 'Selected', 'Rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(internship_id, email)
);

-- Enable Row Level Security
ALTER TABLE internship_applications ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "HR can view all internship applications" ON internship_applications;
DROP POLICY IF EXISTS "Anyone can create internship applications" ON internship_applications;
DROP POLICY IF EXISTS "HR can update internship applications" ON internship_applications;
DROP POLICY IF EXISTS "HR can delete internship applications" ON internship_applications;

-- Policy: HR can view all internship applications
CREATE POLICY "HR can view all internship applications"
  ON internship_applications
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Policy: Anyone can create internship applications
CREATE POLICY "Anyone can create internship applications"
  ON internship_applications
  FOR INSERT
  WITH CHECK (true);

-- Policy: HR can update internship applications
CREATE POLICY "HR can update internship applications"
  ON internship_applications
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Policy: HR can delete internship applications
CREATE POLICY "HR can delete internship applications"
  ON internship_applications
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Create indexes
CREATE INDEX IF NOT EXISTS internship_applications_internship_id_idx ON internship_applications(internship_id);
CREATE INDEX IF NOT EXISTS internship_applications_email_idx ON internship_applications(email);
CREATE INDEX IF NOT EXISTS internship_applications_status_idx ON internship_applications(status);

-- ============================================================================
-- 5. TRIGGERS FOR UPDATED_AT
-- ============================================================================

-- Trigger for jobs
DROP TRIGGER IF EXISTS update_jobs_updated_at ON jobs;
CREATE TRIGGER update_jobs_updated_at
  BEFORE UPDATE ON jobs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for internships
DROP TRIGGER IF EXISTS update_internships_updated_at ON internships;
CREATE TRIGGER update_internships_updated_at
  BEFORE UPDATE ON internships
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for job_applications
DROP TRIGGER IF EXISTS update_job_applications_updated_at ON job_applications;
CREATE TRIGGER update_job_applications_updated_at
  BEFORE UPDATE ON job_applications
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for internship_applications
DROP TRIGGER IF EXISTS update_internship_applications_updated_at ON internship_applications;
CREATE TRIGGER update_internship_applications_updated_at
  BEFORE UPDATE ON internship_applications
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 6. VERIFICATION QUERIES
-- ============================================================================

-- Check if tables were created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('jobs', 'internships', 'job_applications', 'internship_applications');

-- Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename IN ('jobs', 'internships', 'job_applications', 'internship_applications')
ORDER BY tablename, policyname;

-- ============================================================================
-- SETUP COMPLETE!
-- ============================================================================
-- Next steps:
-- 1. Verify tables are created in Supabase Table Editor
-- 2. Update Flutter services to use Supabase instead of in-memory storage
-- 3. Test creating jobs, internships, and managing applications
-- ============================================================================
