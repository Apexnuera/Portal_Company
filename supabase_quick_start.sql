-- ============================================================================
-- QUICK START: CREATE TEST USERS AND ASSIGN ROLES
-- ============================================================================
-- Run this AFTER you've created users in Supabase Auth UI
-- This script will automatically assign roles to users based on their email
-- ============================================================================

-- ============================================================================
-- STEP 1: CREATE USERS IN SUPABASE AUTH UI FIRST!
-- ============================================================================
-- Go to: Authentication > Users > Add User
-- Create these users:
--   1. Email: hr@apexnuera.com, Password: (your choice), Auto-confirm: YES
--   2. Email: employee@apexnuera.com, Password: (your choice), Auto-confirm: YES
--   3. Email: hr.admin@apexnuera.com, Password: (your choice), Auto-confirm: YES
--   4. Email: john.doe@apexnuera.com, Password: (your choice), Auto-confirm: YES
-- ============================================================================

-- ============================================================================
-- STEP 2: RUN THIS SCRIPT
-- ============================================================================

-- Assign HR role to HR users
INSERT INTO user_roles (id, role, email)
SELECT id, 'hr', email 
FROM auth.users 
WHERE email IN ('hr@apexnuera.com', 'hr.admin@apexnuera.com')
ON CONFLICT (id) DO UPDATE SET role = 'hr', email = EXCLUDED.email;

-- Assign Employee role to Employee users
INSERT INTO user_roles (id, role, email)
SELECT id, 'employee', email 
FROM auth.users 
WHERE email IN ('employee@apexnuera.com', 'john.doe@apexnuera.com')
ON CONFLICT (id) DO UPDATE SET role = 'employee', email = EXCLUDED.email;

-- ============================================================================
-- STEP 3: CREATE EMPLOYEE PROFILES (OPTIONAL)
-- ============================================================================

-- Create profile for employee@apexnuera.com
INSERT INTO employee_profiles (
  id, 
  email, 
  full_name, 
  employee_id, 
  department, 
  position, 
  date_of_joining,
  phone,
  city,
  country
)
SELECT 
  id, 
  email, 
  'Test Employee', 
  'EMP001', 
  'Engineering', 
  'Software Developer',
  CURRENT_DATE,
  '+1234567890',
  'San Francisco',
  'USA'
FROM auth.users 
WHERE email = 'employee@apexnuera.com'
ON CONFLICT (id) DO UPDATE SET
  full_name = 'Test Employee',
  employee_id = 'EMP001',
  department = 'Engineering',
  position = 'Software Developer';

-- Create profile for john.doe@apexnuera.com
INSERT INTO employee_profiles (
  id, 
  email, 
  full_name, 
  employee_id, 
  department, 
  position, 
  date_of_joining,
  phone,
  city,
  country
)
SELECT 
  id, 
  email, 
  'John Doe', 
  'EMP002', 
  'Marketing', 
  'Marketing Manager',
  CURRENT_DATE - INTERVAL '1 year',
  '+1234567891',
  'New York',
  'USA'
FROM auth.users 
WHERE email = 'john.doe@apexnuera.com'
ON CONFLICT (id) DO UPDATE SET
  full_name = 'John Doe',
  employee_id = 'EMP002',
  department = 'Marketing',
  position = 'Marketing Manager';

-- ============================================================================
-- STEP 4: VERIFY THE SETUP
-- ============================================================================

-- Check all users with their roles
SELECT 
  u.email,
  ur.role,
  ep.full_name,
  ep.employee_id,
  ep.department,
  ep.position,
  u.created_at
FROM auth.users u
LEFT JOIN user_roles ur ON u.id = ur.id
LEFT JOIN employee_profiles ep ON u.id = ep.id
ORDER BY ur.role, u.email;

-- ============================================================================
-- EXPECTED OUTPUT:
-- ============================================================================
-- email                      | role     | full_name      | employee_id | department  | position
-- ---------------------------|----------|----------------|-------------|-------------|------------------
-- employee@apexnuera.com     | employee | Test Employee  | EMP001      | Engineering | Software Developer
-- john.doe@apexnuera.com     | employee | John Doe       | EMP002      | Marketing   | Marketing Manager
-- hr@apexnuera.com           | hr       | NULL           | NULL        | NULL        | NULL
-- hr.admin@apexnuera.com     | hr       | NULL           | NULL        | NULL        | NULL
-- ============================================================================

-- ============================================================================
-- TROUBLESHOOTING
-- ============================================================================

-- If no rows are inserted, check if users exist:
-- SELECT id, email, created_at FROM auth.users;

-- If you see errors about duplicate keys, users already have roles assigned
-- To update existing roles, use:
-- UPDATE user_roles SET role = 'hr' WHERE email = 'user@example.com';

-- To delete a role assignment:
-- DELETE FROM user_roles WHERE email = 'user@example.com';

-- ============================================================================
-- DONE!
-- ============================================================================
-- You can now test login in your Flutter app with these credentials:
-- 
-- HR Login:
--   Email: hr@apexnuera.com
--   Password: (the password you set in Auth UI)
-- 
-- Employee Login:
--   Email: employee@apexnuera.com
--   Password: (the password you set in Auth UI)
-- ============================================================================
