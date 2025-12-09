-- Comprehensive Employee Profile Schema for Supabase
-- This schema stores complete employee data including personal, professional, compensation, and tax info
-- Run this AFTER supabase_user_roles_policy_v2.sql

-- ============================================================================
-- 1. EMPLOYEE PROFILES TABLE (Extended from basic employees table)
-- ============================================================================

-- Drop and recreate employees table with complete fields
DROP TABLE IF EXISTS employee_profiles CASCADE;

CREATE TABLE employee_profiles (
  -- Identity
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  employee_id TEXT UNIQUE NOT NULL,
  
  -- Personal Details
  full_name TEXT NOT NULL,
  family_name TEXT,
  corporate_email TEXT NOT NULL UNIQUE,
  personal_email TEXT,
  mobile_number TEXT,
  alternate_mobile_number TEXT,
  current_address TEXT,
  permanent_address TEXT,
  pan_id TEXT,
  aadhar_id TEXT,
  date_of_birth DATE,
  blood_group TEXT,
  
  -- Assets
  assigned_assets TEXT[], -- Array of asset names
  other_assets TEXT,
  
  -- Profile Image
  profile_image_url TEXT, -- URL to profile image in storage
  
  -- Bank Details  
  bank_account_holder_name TEXT,
  bank_account_number TEXT,
  bank_ifsc_code TEXT,
  bank_name TEXT,
  bank_details_locked BOOLEAN DEFAULT false,
  
  -- Current Project
  current_project_name TEXT,
  current_project_duration TEXT,
  current_project_manager TEXT,
  
  -- Professional Details
  position TEXT,
  department TEXT,
  manager_name TEXT,
  employment_type TEXT,
  location TEXT,
  work_space TEXT,
  job_level TEXT,
  start_date DATE,
  confirmation_date DATE,
  skills TEXT,
  
  -- Compensation
  basic_salary DECIMAL(12, 2) DEFAULT 0,
  gross_salary DECIMAL(12, 2) DEFAULT 0,
  net_salary DECIMAL(12, 2) DEFAULT 0,
  travel_allowance DECIMAL(12, 2) DEFAULT 0,
  
  -- Tax Info
  tax_regime TEXT, -- 'New' or 'Old'
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES auth.users(id)
);

-- ============================================================================
-- 2. PROJECT HISTORY TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS project_allocations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_profile_id UUID REFERENCES employee_profiles(id) ON DELETE CASCADE,
  project_name TEXT NOT NULL,
  duration TEXT,
  reporting_manager TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- 3. EDUCATION HISTORY TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS education_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_profile_id UUID REFERENCES employee_profiles(id) ON DELETE CASCADE,
  level_of_education TEXT,
  institution TEXT,
  degree TEXT,
  year TEXT,
  grade TEXT,
  document_url TEXT, -- URL to document in storage
  document_name TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- 4. EMPLOYMENT HISTORY TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS employment_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_profile_id UUID REFERENCES employee_profiles(id) ON DELETE CASCADE,
  company_name TEXT,
  designation TEXT,
  from_date DATE,
  to_date DATE,
  document_url TEXT, -- URL to document in storage
  document_name TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- 5. COMPENSATION DOCUMENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS compensation_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_profile_id UUID REFERENCES employee_profiles(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL, -- 'payslip', 'bonus', 'benefit', 'letter', 'offer', 'reimbursement', 'policy'
  document_name TEXT NOT NULL,
  document_url TEXT NOT NULL, -- URL to document in storage
  upload_date TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- 6. INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_employee_profiles_auth_user ON employee_profiles(auth_user_id);
CREATE INDEX IF NOT EXISTS idx_employee_profiles_employee_id ON employee_profiles(employee_id);
CREATE INDEX IF NOT EXISTS idx_employee_profiles_corporate_email ON employee_profiles(corporate_email);
CREATE INDEX IF NOT EXISTS idx_project_allocations_employee ON project_allocations(employee_profile_id);
CREATE INDEX IF NOT EXISTS idx_education_entries_employee ON education_entries(employee_profile_id);
CREATE INDEX IF NOT EXISTS idx_employment_entries_employee ON employment_entries(employee_profile_id);
CREATE INDEX IF NOT EXISTS idx_compensation_documents_employee ON compensation_documents(employee_profile_id);
CREATE INDEX IF NOT EXISTS idx_compensation_documents_type ON compensation_documents(document_type);

-- ============================================================================
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE employee_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE education_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE employment_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE compensation_documents ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "HR can view all profiles" ON employee_profiles;
DROP POLICY IF EXISTS "HR can insert profiles" ON employee_profiles;
DROP POLICY IF EXISTS "HR can update profiles" ON employee_profiles;
DROP POLICY IF EXISTS "HR can delete profiles" ON employee_profiles;
DROP POLICY IF EXISTS "Employees can view own profile" ON employee_profiles;
DROP POLICY IF EXISTS "Employees can update own profile" ON employee_profiles;

DROP POLICY IF EXISTS "HR can manage all projects" ON project_allocations;
DROP POLICY IF EXISTS "Employees can view own projects" ON project_allocations;
DROP POLICY IF EXISTS "Employees can update own projects" ON project_allocations;

DROP POLICY IF EXISTS "HR can manage all education" ON education_entries;
DROP POLICY IF EXISTS "Employees can view own education" ON education_entries;
DROP POLICY IF EXISTS "Employees can update own education" ON education_entries;

DROP POLICY IF EXISTS "HR can manage all employment" ON employment_entries;
DROP POLICY IF EXISTS "Employees can view own employment" ON employment_entries;
DROP POLICY IF EXISTS "Employees can update own employment" ON employment_entries;

DROP POLICY IF EXISTS "HR can manage all compensation docs" ON compensation_documents;
DROP POLICY IF EXISTS "Employees can view own compensation docs" ON compensation_documents;

-- Employee Profiles Policies
CREATE POLICY "HR can view all profiles"
  ON employee_profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

CREATE POLICY "HR can insert profiles"
  ON employee_profiles FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

CREATE POLICY "HR can update profiles"
  ON employee_profiles FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

CREATE POLICY "HR can delete profiles"
  ON employee_profiles FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

CREATE POLICY "Employees can view own profile"
  ON employee_profiles FOR SELECT
  USING (auth.uid() = auth_user_id);

CREATE POLICY "Employees can update own profile"
  ON employee_profiles FOR UPDATE
  USING (auth.uid() = auth_user_id)
  WITH CHECK (auth.uid() = auth_user_id);

-- Project Allocations Policies
CREATE POLICY "HR can manage all projects"
  ON project_allocations FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

CREATE POLICY "Employees can view own projects"
  ON project_allocations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM employee_profiles
      WHERE employee_profiles.id = project_allocations.employee_profile_id
      AND employee_profiles.auth_user_id = auth.uid()
    )
  );

CREATE POLICY "Employees can update own projects"
  ON project_allocations FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM employee_profiles
      WHERE employee_profiles.id = project_allocations.employee_profile_id
      AND employee_profiles.auth_user_id = auth.uid()
    )
  );

-- Education Entries Policies
CREATE POLICY "HR can manage all education"
  ON education_entries FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

CREATE POLICY "Employees can view own education"
  ON education_entries FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM employee_profiles
      WHERE employee_profiles.id = education_entries.employee_profile_id
      AND employee_profiles.auth_user_id = auth.uid()
    )
  );

CREATE POLICY "Employees can update own education"
  ON education_entries FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM employee_profiles
      WHERE employee_profiles.id = education_entries.employee_profile_id
      AND employee_profiles.auth_user_id = auth.uid()
    )
  );

-- Employment Entries Policies
CREATE POLICY "HR can manage all employment"
  ON employment_entries FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

CREATE POLICY "Employees can view own employment"
  ON employment_entries FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM employee_profiles
      WHERE employee_profiles.id = employment_entries.employee_profile_id
      AND employee_profiles.auth_user_id = auth.uid()
    )
  );

CREATE POLICY "Employees can update own employment"
  ON employment_entries FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM employee_profiles
      WHERE employee_profiles.id = employment_entries.employee_profile_id
      AND employee_profiles.auth_user_id = auth.uid()
    )
  );

-- Compensation Documents Policies
CREATE POLICY "HR can manage all compensation docs"
  ON compensation_documents FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

CREATE POLICY "Employees can view own compensation docs"
  ON compensation_documents FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM employee_profiles
      WHERE employee_profiles.id = compensation_documents.employee_profile_id
      AND employee_profiles.auth_user_id = auth.uid()
    )
  );

-- ============================================================================
-- 8. FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_employee_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
DROP TRIGGER IF EXISTS employee_profiles_updated_at ON employee_profiles;
CREATE TRIGGER employee_profiles_updated_at
  BEFORE UPDATE ON employee_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_employee_profiles_updated_at();

-- ============================================================================
-- 9. STORAGE BUCKETS
-- ============================================================================

-- Create storage buckets for employee documents
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('employee-profiles', 'employee-profiles', false),
  ('employee-documents', 'employee-documents', false),
  ('compensation-docs', 'compensation-docs', false)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for employee-profiles bucket (profile images)
DROP POLICY IF EXISTS "HR can upload profile images" ON storage.objects;
DROP POLICY IF EXISTS "HR can view profile images" ON storage.objects;
DROP POLICY IF EXISTS "Employees can view own profile image" ON storage.objects;
DROP POLICY IF EXISTS "Employees can upload own profile image" ON storage.objects;

CREATE POLICY "HR can upload profile images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'employee-profiles'
    AND EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

CREATE POLICY "HR can view profile images"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'employee-profiles'
    AND EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

CREATE POLICY "Employees can view own profile image"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'employee-profiles'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Employees can upload own profile image"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'employee-profiles'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Storage policies for employee-documents bucket (education/employment docs)
DROP POLICY IF EXISTS "HR can manage employee documents" ON storage.objects;
DROP POLICY IF EXISTS "Employees can manage own documents" ON storage.objects;

CREATE POLICY "HR can manage employee documents"
  ON storage.objects FOR ALL
  USING (
    bucket_id = 'employee-documents'
    AND EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

CREATE POLICY "Employees can manage own documents"
  ON storage.objects FOR ALL
  USING (
    bucket_id = 'employee-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Storage policies for compensation-docs bucket
DROP POLICY IF EXISTS "HR can manage compensation documents" ON storage.objects;
DROP POLICY IF EXISTS "Employees can view own compensation documents" ON storage.objects;

CREATE POLICY "HR can manage compensation documents"
  ON storage.objects FOR ALL
  USING (
    bucket_id = 'compensation-docs'
    AND EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

CREATE POLICY "Employees can view own compensation documents"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'compensation-docs'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- ============================================================================
-- 10. GRANT PERMISSIONS
-- ============================================================================

GRANT ALL ON employee_profiles TO authenticated;
GRANT ALL ON project_allocations TO authenticated;
GRANT ALL ON education_entries TO authenticated;
GRANT ALL ON employment_entries TO authenticated;
GRANT ALL ON compensation_documents TO authenticated;

-- ============================================================================
-- 11. ENABLE REALTIME
-- ============================================================================

ALTER PUBLICATION supabase_realtime ADD TABLE employee_profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE project_allocations;
ALTER PUBLICATION supabase_realtime ADD TABLE education_entries;
ALTER PUBLICATION supabase_realtime ADD TABLE employment_entries;
ALTER PUBLICATION supabase_realtime ADD TABLE compensation_documents;
