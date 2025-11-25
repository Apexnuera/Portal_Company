-- FIX INFINITE RECURSION IN RLS POLICIES
-- Run this script to fix the "infinite recursion detected" error (Code: 42P17)

-- 1. Create a secure function to check HR role without triggering RLS recursion
CREATE OR REPLACE FUNCTION public.is_hr()
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if the current user has 'hr' role
  -- We access the table directly, but this function is used inside policies
  RETURN EXISTS (
    SELECT 1
    FROM user_roles
    WHERE id = auth.uid()
    AND role = 'hr'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; -- SECURITY DEFINER allows bypassing RLS within the function

-- 2. Drop existing problematic policies
DROP POLICY IF EXISTS "HR can view all roles" ON user_roles;
DROP POLICY IF EXISTS "HR can assign employee roles" ON user_roles;
DROP POLICY IF EXISTS "HR can update employee roles" ON user_roles;
DROP POLICY IF EXISTS "HR can delete employee roles" ON user_roles;

-- 3. Re-create policies using the non-recursive function

-- Allow HR to VIEW ALL roles
CREATE POLICY "HR can view all roles"
  ON user_roles
  FOR SELECT
  USING (
    public.is_hr() -- Uses the function instead of direct table query
  );

-- Allow HR to INSERT 'employee' roles
CREATE POLICY "HR can assign employee roles"
  ON user_roles
  FOR INSERT
  WITH CHECK (
    public.is_hr() -- User must be HR
    AND role = 'employee' -- Can only assign 'employee' role
  );

-- Allow HR to UPDATE 'employee' roles
CREATE POLICY "HR can update employee roles"
  ON user_roles
  FOR UPDATE
  USING (
    public.is_hr()
  )
  WITH CHECK (
    role = 'employee'
  );

-- Allow HR to DELETE 'employee' roles
CREATE POLICY "HR can delete employee roles"
  ON user_roles
  FOR DELETE
  USING (
    public.is_hr()
    AND role = 'employee'
  );

-- Note: "Users can read their own role" policy is fine and doesn't cause recursion
-- because it only checks auth.uid() = id, not querying the table for other rows.
