-- ============================================================================
-- COMPLETE SUPABASE SETUP SCRIPT FOR APEXNUERA PORTAL
-- ============================================================================
-- This script sets up all necessary tables, policies, and functions
-- for HR and Employee authentication and management
-- 
-- Run this script in your Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- 1. USER ROLES TABLE
-- ============================================================================
-- Stores role assignments for users (hr or employee)

CREATE TABLE IF NOT EXISTS user_roles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  role TEXT NOT NULL CHECK (role IN ('hr', 'employee')),
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can read their own role" ON user_roles;
DROP POLICY IF EXISTS "Service role can manage user roles" ON user_roles;

-- Policy: Users can read their own role
CREATE POLICY "Users can read their own role"
  ON user_roles
  FOR SELECT
  USING (auth.uid() = id);

-- Policy: Authenticated users can read all roles (needed for HR to see employees)
CREATE POLICY "Authenticated users can read all roles"
  ON user_roles
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Policy: Only service role can insert/update/delete roles
CREATE POLICY "Service role can manage user roles"
  ON user_roles
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS user_roles_email_idx ON user_roles(email);
CREATE INDEX IF NOT EXISTS user_roles_role_idx ON user_roles(role);

-- ============================================================================
-- 2. EMPLOYEE PROFILES TABLE
-- ============================================================================
-- Stores detailed employee information

CREATE TABLE IF NOT EXISTS employee_profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  employee_id TEXT UNIQUE,
  department TEXT,
  position TEXT,
  phone TEXT,
  date_of_birth DATE,
  date_of_joining DATE,
  manager_id UUID REFERENCES employee_profiles(id),
  profile_picture_url TEXT,
  address TEXT,
  city TEXT,
  state TEXT,
  country TEXT,
  postal_code TEXT,
  emergency_contact_name TEXT,
  emergency_contact_phone TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE employee_profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can read their own profile" ON employee_profiles;
DROP POLICY IF EXISTS "HR can read all profiles" ON employee_profiles;
DROP POLICY IF EXISTS "HR can manage profiles" ON employee_profiles;

-- Policy: Users can read their own profile
CREATE POLICY "Users can read their own profile"
  ON employee_profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Policy: HR can read all profiles
CREATE POLICY "HR can read all profiles"
  ON employee_profiles
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Policy: HR can insert/update/delete profiles
CREATE POLICY "HR can manage profiles"
  ON employee_profiles
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Create indexes
CREATE INDEX IF NOT EXISTS employee_profiles_email_idx ON employee_profiles(email);
CREATE INDEX IF NOT EXISTS employee_profiles_employee_id_idx ON employee_profiles(employee_id);
CREATE INDEX IF NOT EXISTS employee_profiles_department_idx ON employee_profiles(department);

-- ============================================================================
-- 3. HELPER FUNCTIONS
-- ============================================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for user_roles
DROP TRIGGER IF EXISTS update_user_roles_updated_at ON user_roles;
CREATE TRIGGER update_user_roles_updated_at
  BEFORE UPDATE ON user_roles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for employee_profiles
DROP TRIGGER IF EXISTS update_employee_profiles_updated_at ON employee_profiles;
CREATE TRIGGER update_employee_profiles_updated_at
  BEFORE UPDATE ON employee_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 4. HELPER FUNCTION TO CREATE USER WITH ROLE
-- ============================================================================
-- This function helps create a user and assign a role in one operation
-- Note: This is for reference only - user creation must be done via Supabase Auth UI or API

CREATE OR REPLACE FUNCTION assign_user_role(
  user_id UUID,
  user_email TEXT,
  user_role TEXT
)
RETURNS void AS $$
BEGIN
  INSERT INTO user_roles (id, role, email)
  VALUES (user_id, user_role, user_email)
  ON CONFLICT (id) DO UPDATE
  SET role = user_role, email = user_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 5. VIEWS FOR EASY QUERYING
-- ============================================================================

-- View: All users with their roles
CREATE OR REPLACE VIEW users_with_roles AS
SELECT 
  u.id,
  u.email,
  ur.role,
  ep.full_name,
  ep.employee_id,
  ep.department,
  ep.position,
  ur.created_at as role_assigned_at,
  u.created_at as user_created_at
FROM auth.users u
LEFT JOIN user_roles ur ON u.id = ur.id
LEFT JOIN employee_profiles ep ON u.id = ep.id
ORDER BY u.created_at DESC;

-- ============================================================================
-- 6. SAMPLE DATA (OPTIONAL - COMMENT OUT IF NOT NEEDED)
-- ============================================================================

-- NOTE: Before running this section, you must:
-- 1. Create users in Supabase Auth UI (Authentication > Users > Add User)
-- 2. Get their UUIDs from auth.users table
-- 3. Replace the UUIDs below with actual user IDs

-- Example: To get user IDs, run:
-- SELECT id, email FROM auth.users;

-- Then uncomment and modify the following:

/*
-- Assign HR role to a user
INSERT INTO user_roles (id, role, email)
SELECT id, 'hr', email 
FROM auth.users 
WHERE email = 'hr@test.com'
ON CONFLICT (id) DO UPDATE SET role = 'hr';

-- Assign Employee role to a user
INSERT INTO user_roles (id, role, email)
SELECT id, 'employee', email 
FROM auth.users 
WHERE email = 'employee@test.com'
ON CONFLICT (id) DO UPDATE SET role = 'employee';

-- Create employee profile
INSERT INTO employee_profiles (id, email, full_name, employee_id, department, position, date_of_joining)
SELECT 
  id, 
  email, 
  'John Doe', 
  'EMP001', 
  'Engineering', 
  'Software Developer',
  NOW()
FROM auth.users 
WHERE email = 'employee@test.com'
ON CONFLICT (id) DO NOTHING;
*/

-- ============================================================================
-- 7. VERIFICATION QUERIES
-- ============================================================================

-- Run these queries after setup to verify everything is working:

-- Check if tables were created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('user_roles', 'employee_profiles');

-- Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('user_roles', 'employee_profiles');

-- Check all users with roles (after creating test users)
-- SELECT * FROM users_with_roles;

-- ============================================================================
-- SETUP COMPLETE!
-- ============================================================================
-- Next steps:
-- 1. Create test users in Supabase Auth UI
-- 2. Assign roles using the INSERT statements in section 6
-- 3. Test login in your Flutter app
-- ============================================================================
