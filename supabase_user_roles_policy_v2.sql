-- ROBUST FIX for User Roles RLS Policy
-- Run this in Supabase SQL Editor to fix "new row violates row-level security policy" error

-- 1. Drop potential conflicting policies to ensure a clean slate
DROP POLICY IF EXISTS "HR can assign employee roles" ON user_roles;
DROP POLICY IF EXISTS "HR can view all roles" ON user_roles;
DROP POLICY IF EXISTS "Service role can manage user roles" ON user_roles;
DROP POLICY IF EXISTS "Users can read their own role" ON user_roles;

-- 2. Re-create standard policies

-- Allow users to read their own role (Essential for login)
CREATE POLICY "Users can read their own role"
  ON user_roles
  FOR SELECT
  USING (auth.uid() = id);

-- Allow Service Role (Admin) full access
CREATE POLICY "Service role can manage user roles"
  ON user_roles
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

-- 3. Add HR specific policies

-- Allow HR to VIEW ALL roles (Required to check if users exist)
CREATE POLICY "HR can view all roles"
  ON user_roles
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Allow HR to INSERT 'employee' roles
-- This fixes the 42501 error when creating employees
CREATE POLICY "HR can assign employee roles"
  ON user_roles
  FOR INSERT
  WITH CHECK (
    -- User must be HR
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
    -- Can only assign 'employee' role
    AND role = 'employee'
  );

-- 4. Allow HR to UPDATE 'employee' roles (In case of corrections)
CREATE POLICY "HR can update employee roles"
  ON user_roles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  )
  WITH CHECK (
    role = 'employee'
  );

-- 5. Allow HR to DELETE 'employee' roles
CREATE POLICY "HR can delete employee roles"
  ON user_roles
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
    AND role = 'employee'
  );
