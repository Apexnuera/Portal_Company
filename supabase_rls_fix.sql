-- Fix for infinite recursion in user_roles RLS policies
-- This resolves the PostgrestException: infinite recursion detected in policy for relation "user_roles"

-- Step 1: Drop all existing policies on user_roles
DROP POLICY IF EXISTS "Users can read own role" ON user_roles;
DROP POLICY IF EXISTS "HR can read all roles" ON user_roles;
DROP POLICY IF EXISTS "Service role can manage roles" ON user_roles;

-- Step 2: Create a security definer function to check if a user is HR
-- This function runs with elevated privileges and bypasses RLS
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

-- Step 3: Create simplified policies that avoid circular dependencies

-- Policy 1: Users can always read their own role
-- This is safe because it doesn't query user_roles recursively
CREATE POLICY "Users can read own role" ON user_roles
  FOR SELECT
  USING (auth.uid() = id);

-- Policy 2: HR users can read all roles
-- Uses the security definer function to avoid recursion
CREATE POLICY "HR can read all roles" ON user_roles
  FOR SELECT
  USING (is_hr_user(auth.uid()));

-- Policy 3: HR users can insert new roles (for creating employees)
CREATE POLICY "HR can insert roles" ON user_roles
  FOR INSERT
  WITH CHECK (is_hr_user(auth.uid()));

-- Policy 4: HR users can update roles
CREATE POLICY "HR can update roles" ON user_roles
  FOR UPDATE
  USING (is_hr_user(auth.uid()))
  WITH CHECK (is_hr_user(auth.uid()));

-- Policy 5: HR users can delete roles
CREATE POLICY "HR can delete roles" ON user_roles
  FOR DELETE
  USING (is_hr_user(auth.uid()));

-- Step 4: Ensure RLS is enabled
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Step 5: Grant necessary permissions
GRANT SELECT ON user_roles TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

-- Verification query - check that policies are correctly set up
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd as operation,
  roles
FROM pg_policies
WHERE tablename = 'user_roles'
ORDER BY policyname;
