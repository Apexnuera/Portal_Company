-- FIX: Infinite Recursion in User Roles RLS
-- This script fixes the "new row violates row-level security policy" error
-- by preventing infinite recursion when checking HR permissions.

-- 1. Create a secure function to check HR role
-- SECURITY DEFINER means this function runs with admin privileges, bypassing RLS
CREATE OR REPLACE FUNCTION public.is_hr()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE id = auth.uid()
    AND role = 'hr'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Drop existing problematic policies
DROP POLICY IF EXISTS "HR can assign employee roles" ON user_roles;
DROP POLICY IF EXISTS "HR can view all roles" ON user_roles;
DROP POLICY IF EXISTS "HR can update employee roles" ON user_roles;
DROP POLICY IF EXISTS "HR can delete employee roles" ON user_roles;
DROP POLICY IF EXISTS "Users can read their own role" ON user_roles;
DROP POLICY IF EXISTS "Service role can manage user roles" ON user_roles;

-- 3. Re-create policies using the secure function

-- Allow users to read their own role
CREATE POLICY "Users can read their own role"
  ON user_roles
  FOR SELECT
  USING (auth.uid() = id);

-- Allow Service Role (Admin) full access
CREATE POLICY "Service role can manage user roles"
  ON user_roles
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

-- Allow HR to VIEW ALL roles
CREATE POLICY "HR can view all roles"
  ON user_roles
  FOR SELECT
  USING (is_hr());

-- Allow HR to INSERT 'employee' roles
CREATE POLICY "HR can assign employee roles"
  ON user_roles
  FOR INSERT
  WITH CHECK (
    is_hr() 
    AND role = 'employee'
  );

-- Allow HR to UPDATE 'employee' roles
CREATE POLICY "HR can update employee roles"
  ON user_roles
  FOR UPDATE
  USING (is_hr())
  WITH CHECK (role = 'employee');

-- Allow HR to DELETE 'employee' roles
CREATE POLICY "HR can delete employee roles"
  ON user_roles
  FOR DELETE
  USING (
    is_hr() 
    AND role = 'employee'
  );

-- 4. Grant execute permission on the function
GRANT EXECUTE ON FUNCTION public.is_hr() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_hr() TO anon;
