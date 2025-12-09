-- Jobs and Internships Schema for Supabase
-- This script is idempotent - safe to run multiple times

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public read access for jobs" ON jobs;
DROP POLICY IF EXISTS "HR can insert jobs" ON jobs;
DROP POLICY IF EXISTS "HR can update jobs" ON jobs;
DROP POLICY IF EXISTS "HR can delete jobs" ON jobs;

DROP POLICY IF EXISTS "Public read access for internships" ON internships;
DROP POLICY IF EXISTS "HR can insert internships" ON internships;
DROP POLICY IF EXISTS "HR can update internships" ON internships;
DROP POLICY IF EXISTS "HR can delete internships" ON internships;

DROP POLICY IF EXISTS "Public insert access for job applications" ON job_applications;
DROP POLICY IF EXISTS "HR can read job applications" ON job_applications;
DROP POLICY IF EXISTS "Applicant can read own job application" ON job_applications;
DROP POLICY IF EXISTS "HR can update job applications" ON job_applications;
DROP POLICY IF EXISTS "HR can delete job applications" ON job_applications;

DROP POLICY IF EXISTS "Public insert access for internship applications" ON internship_applications;
DROP POLICY IF EXISTS "HR can read internship applications" ON internship_applications;
DROP POLICY IF EXISTS "Applicant can read own internship application" ON internship_applications;
DROP POLICY IF EXISTS "HR can update internship applications" ON internship_applications;
DROP POLICY IF EXISTS "HR can delete internship applications" ON internship_applications;

-- Jobs Table
CREATE TABLE IF NOT EXISTS jobs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  location TEXT NOT NULL,
  contract_type TEXT NOT NULL,
  department TEXT NOT NULL,
  posting_date DATE NOT NULL,
  application_deadline DATE NOT NULL,
  experience TEXT NOT NULL,
  skills TEXT[] NOT NULL,
  responsibilities TEXT[] NOT NULL,
  qualifications TEXT[] NOT NULL,
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
  location TEXT NOT NULL,
  contract_type TEXT NOT NULL,
  posting_date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Job Applications Table
CREATE TABLE IF NOT EXISTS job_applications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  resume_name TEXT NOT NULL,
  resume_data TEXT, -- Storing base64 for now as per existing app logic
  status TEXT DEFAULT 'In Progress',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Internship Applications Table
CREATE TABLE IF NOT EXISTS internship_applications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  internship_id UUID REFERENCES internships(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  resume_name TEXT NOT NULL,
  resume_data TEXT, -- Storing base64 for now
  status TEXT DEFAULT 'In Progress',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE internships ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE internship_applications ENABLE ROW LEVEL SECURITY;

-- Policies for Jobs
CREATE POLICY "Public read access for jobs" ON jobs FOR SELECT USING (true);
CREATE POLICY "HR can insert jobs" ON jobs FOR INSERT WITH CHECK (is_hr_user(auth.uid()));
CREATE POLICY "HR can update jobs" ON jobs FOR UPDATE USING (is_hr_user(auth.uid()));
CREATE POLICY "HR can delete jobs" ON jobs FOR DELETE USING (is_hr_user(auth.uid()));

-- Policies for Internships
CREATE POLICY "Public read access for internships" ON internships FOR SELECT USING (true);
CREATE POLICY "HR can insert internships" ON internships FOR INSERT WITH CHECK (is_hr_user(auth.uid()));
CREATE POLICY "HR can update internships" ON internships FOR UPDATE USING (is_hr_user(auth.uid()));
CREATE POLICY "HR can delete internships" ON internships FOR DELETE USING (is_hr_user(auth.uid()));

-- Policies for Job Applications
CREATE POLICY "Public insert access for job applications" ON job_applications FOR INSERT WITH CHECK (true);
CREATE POLICY "HR can read job applications" ON job_applications FOR SELECT USING (is_hr_user(auth.uid()));
CREATE POLICY "Applicant can read own job application" ON job_applications FOR SELECT USING (
  email = (SELECT email FROM auth.users WHERE id = auth.uid())
);
CREATE POLICY "HR can update job applications" ON job_applications FOR UPDATE USING (is_hr_user(auth.uid()));
CREATE POLICY "HR can delete job applications" ON job_applications FOR DELETE USING (is_hr_user(auth.uid()));

-- Policies for Internship Applications
CREATE POLICY "Public insert access for internship applications" ON internship_applications FOR INSERT WITH CHECK (true);
CREATE POLICY "HR can read internship applications" ON internship_applications FOR SELECT USING (is_hr_user(auth.uid()));
CREATE POLICY "Applicant can read own internship application" ON internship_applications FOR SELECT USING (
  email = (SELECT email FROM auth.users WHERE id = auth.uid())
);
CREATE POLICY "HR can update internship applications" ON internship_applications FOR UPDATE USING (is_hr_user(auth.uid()));
CREATE POLICY "HR can delete internship applications" ON internship_applications FOR DELETE USING (is_hr_user(auth.uid()));

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS jobs_created_at_idx ON jobs(created_at DESC);
CREATE INDEX IF NOT EXISTS internships_created_at_idx ON internships(created_at DESC);
CREATE INDEX IF NOT EXISTS job_applications_job_id_idx ON job_applications(job_id);
CREATE INDEX IF NOT EXISTS job_applications_created_at_idx ON job_applications(created_at DESC);
CREATE INDEX IF NOT EXISTS internship_applications_internship_id_idx ON internship_applications(internship_id);
CREATE INDEX IF NOT EXISTS internship_applications_created_at_idx ON internship_applications(created_at DESC);
