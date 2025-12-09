-- ============================================================================
-- STEP 1: CREATE/UPDATE EMPLOYEE PROFILES TABLE
-- Run this in Supabase SQL Editor
-- ============================================================================

-- First, check if table exists and has all columns
-- If table exists but is missing columns, this will add them
-- If table doesn't exist, it will be created

CREATE TABLE IF NOT EXISTS employee_profiles (
  -- Identity
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  employee_id TEXT UNIQUE NOT NULL,
  
  -- Personal Details - Basic Info
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
  
  -- Personal Details - Assets
  assigned_assets TEXT[], -- Array of asset names (Laptop, Mobile, etc.)
  other_assets TEXT,
  
  -- Personal Details - Profile Image
  profile_image_url TEXT,
  
  -- Personal Details - Bank Details  
  bank_account_holder_name TEXT,
  bank_account_number TEXT,
  bank_ifsc_code TEXT,
  bank_name TEXT,
  bank_details_locked BOOLEAN DEFAULT false,
  
  -- Personal Details - Current Project
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

-- Add missing columns if table already exists
-- These will only run if the column doesn't exist

ALTER TABLE employee_profiles 
  ADD COLUMN IF NOT EXISTS family_name TEXT,
  ADD COLUMN IF NOT EXISTS alternate_mobile_number TEXT,
  ADD COLUMN IF NOT EXISTS current_address TEXT,
  ADD COLUMN IF NOT EXISTS permanent_address TEXT,
  ADD COLUMN IF NOT EXISTS pan_id TEXT,
  ADD COLUMN IF NOT EXISTS aadhar_id TEXT,
  ADD COLUMN IF NOT EXISTS date_of_birth DATE,
  ADD COLUMN IF NOT EXISTS blood_group TEXT,
  ADD COLUMN IF NOT EXISTS assigned_assets TEXT[],
  ADD COLUMN IF NOT EXISTS other_assets TEXT,
  ADD COLUMN IF NOT EXISTS profile_image_url TEXT,
  ADD COLUMN IF NOT EXISTS bank_account_holder_name TEXT,
  ADD COLUMN IF NOT EXISTS bank_account_number TEXT,
  ADD COLUMN IF NOT EXISTS bank_ifsc_code TEXT,
  ADD COLUMN IF NOT EXISTS bank_name TEXT,
  ADD COLUMN IF NOT EXISTS bank_details_locked BOOLEAN,
  ADD COLUMN IF NOT EXISTS current_project_name TEXT,
  ADD COLUMN IF NOT EXISTS current_project_duration TEXT,
  ADD COLUMN IF NOT EXISTS current_project_manager TEXT,
  ADD COLUMN IF NOT EXISTS work_space TEXT,
  ADD COLUMN IF NOT EXISTS basic_salary DECIMAL(12, 2),
  ADD COLUMN IF NOT EXISTS gross_salary DECIMAL(12, 2),
  ADD COLUMN IF NOT EXISTS net_salary DECIMAL(12, 2),
  ADD COLUMN IF NOT EXISTS travel_allowance DECIMAL(12, 2),
  ADD COLUMN IF NOT EXISTS tax_regime TEXT;

-- Set defaults for existing rows where bank_details_locked is null
UPDATE employee_profiles 
SET bank_details_locked = false 
WHERE bank_details_locked IS NULL;

-- ============================================================================
-- STEP 2: CREATE SUPPORTING TABLES
-- ============================================================================

-- Project History Table
CREATE TABLE IF NOT EXISTS project_allocations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_profile_id UUID REFERENCES employee_profiles(id) ON DELETE CASCADE,
  project_name TEXT NOT NULL,
  duration TEXT,
  reporting_manager TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Education History Table
CREATE TABLE IF NOT EXISTS education_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_profile_id UUID REFERENCES employee_profiles(id) ON DELETE CASCADE,
  level_of_education TEXT,
  institution TEXT,
  degree TEXT,
  year TEXT,
  grade TEXT,
  document_url TEXT,
  document_name TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Employment History Table
CREATE TABLE IF NOT EXISTS employment_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_profile_id UUID REFERENCES employee_profiles(id) ON DELETE CASCADE,
  company_name TEXT,
  designation TEXT,
  from_date DATE,
  to_date DATE,
  document_url TEXT,
  document_name TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Compensation Documents Table
CREATE TABLE IF NOT EXISTS compensation_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_profile_id UUID REFERENCES employee_profiles(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL,
  document_name TEXT NOT NULL,
  document_url TEXT NOT NULL,
  upload_date TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================================
-- STEP 3: CREATE INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_employee_profiles_auth_user ON employee_profiles(auth_user_id);
CREATE INDEX IF NOT EXISTS idx_employee_profiles_employee_id ON employee_profiles(employee_id);
CREATE INDEX IF NOT EXISTS idx_employee_profiles_corporate_email ON employee_profiles(corporate_email);
CREATE INDEX IF NOT EXISTS idx_project_allocations_employee ON project_allocations(employee_profile_id);
CREATE INDEX IF NOT EXISTS idx_education_entries_employee ON education_entries(employee_profile_id);
CREATE INDEX IF NOT EXISTS idx_employment_entries_employee ON employment_entries(employee_profile_id);
CREATE INDEX IF NOT EXISTS idx_compensation_documents_employee ON compensation_documents(employee_profile_id);

-- ============================================================================
-- STEP 4: ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE employee_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE education_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE employment_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE compensation_documents ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- STEP 5: DROP OLD POLICIES (if they exist)
-- ============================================================================

DROP POLICY IF EXISTS "HR can view all profiles" ON employee_profiles;
DROP POLICY IF EXISTS "HR can insert profiles" ON employee_profiles;
DROP POLICY IF EXISTS "HR can update profiles" ON employee_profiles;
DROP POLICY IF EXISTS "HR can delete profiles" ON employee_profiles;
DROP POLICY IF EXISTS "Employees can view own profile" ON employee_profiles;
DROP POLICY IF EXISTS "Employees can update own profile" ON employee_profiles;

-- ============================================================================
-- STEP 6: CREATE RLS POLICIES
-- ============================================================================

-- Policies for employee_profiles
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

CREATE POLICY "Employees can view own profile"
  ON employee_profiles FOR SELECT
  USING (auth.uid() = auth_user_id);

CREATE POLICY "Employees can update own profile"
  ON employee_profiles FOR UPDATE
  USING (auth.uid() = auth_user_id)
  WITH CHECK (auth.uid() = auth_user_id);

-- ============================================================================
-- STEP 7: CREATE TRIGGER FOR AUTO-UPDATE timestamp
-- ============================================================================

CREATE OR REPLACE FUNCTION update_employee_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS employee_profiles_updated_at ON employee_profiles;
CREATE TRIGGER employee_profiles_updated_at
  BEFORE UPDATE ON employee_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_employee_profiles_updated_at();

-- ============================================================================
-- STEP 8: CREATE STORAGE BUCKETS FOR PROFILE PICTURES
-- ============================================================================

-- Create storage bucket for employee profile pictures
INSERT INTO storage.buckets (id, name, public)
VALUES ('employee-profiles', 'employee-profiles', true) -- Public bucket for profile images
ON CONFLICT (id) DO NOTHING;

-- Storage policies for employee-profiles bucket
DROP POLICY IF EXISTS "Employees can upload own profile picture" ON storage.objects;
DROP POLICY IF EXISTS "Employees can view own profile picture" ON storage.objects;
DROP POLICY IF EXISTS "HR can view all profile pictures" ON storage.objects;
DROP POLICY IF EXISTS "HR can upload profile pictures" ON storage.objects;

CREATE POLICY "Employees can upload own profile picture"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'employee-profiles'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Employees can view own profile picture"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'employee-profiles'
    AND (
      auth.uid()::text = (storage.foldername(name))[1]
      OR EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_roles.id = auth.uid()
        AND user_roles.role = 'hr'
      )
    )
  );

CREATE POLICY "HR can view all profile pictures"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'employee-profiles'
    AND EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

CREATE POLICY "HR can upload profile pictures"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'employee-profiles'
    AND EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- ============================================================================
-- STEP 9: GRANT PERMISSIONS
-- ============================================================================

GRANT ALL ON employee_profiles TO authenticated;
GRANT ALL ON project_allocations TO authenticated;
GRANT ALL ON education_entries TO authenticated;
GRANT ALL ON employment_entries TO authenticated;
GRANT ALL ON compensation_documents TO authenticated;

-- ============================================================================
-- VERIFICATION QUERY
-- Run this to verify the table was created correctly
-- ============================================================================

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'employee_profiles'
ORDER BY ordinal_position;
