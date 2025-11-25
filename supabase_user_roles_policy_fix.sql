-- Fix User Roles RLS Policy for HR Users
-- Run this script in Supabase SQL Editor to allow HR users to create employees

-- 1. Allow HR users to INSERT into user_roles table
-- This is required so HR can assign the 'employee' role to new users
CREATE POLICY "HR can assign employee roles"
  ON user_roles
  FOR INSERT
  WITH CHECK (
    -- The user performing the insert must be an HR user
    EXISTS (
      SELECT 1 FROM user_roles AS ur
      WHERE ur.id = auth.uid()
      AND ur.role = 'hr'
    )
    -- AND they can only assign the 'employee' role (not creating more HRs)
    AND role = 'employee'
  );

-- 2. Allow HR users to SELECT from user_roles (to verify roles)
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

-- Verify policies were created
-- SELECT * FROM pg_policies WHERE tablename = 'user_roles';
