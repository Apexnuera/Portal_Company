-- SQL Script to Fix Employee Deletion RLS Policies
-- Run this in your Supabase SQL Editor

-- First, let's check and fix the RLS policies for employee_profiles table

-- Drop existing policies that might be blocking deletion
DROP POLICY IF EXISTS "HR can delete employee profiles" ON employee_profiles;
DROP POLICY IF EXISTS "HR users can delete employee profiles" ON employee_profiles;

-- Create a comprehensive delete policy for HR users
CREATE POLICY "HR can delete employee profiles"
ON employee_profiles
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_roles.id = auth.uid()
    AND user_roles.role = 'hr'
  )
);

-- Also ensure the is_hr_user function is correct
CREATE OR REPLACE FUNCTION is_hr_user()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_roles
    WHERE id = auth.uid()
    AND role = 'hr'
  );
END;
$$;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION is_hr_user() TO authenticated;

-- Verify RLS is enabled on employee_profiles
ALTER TABLE employee_profiles ENABLE ROW LEVEL SECURITY;

-- Show current policies (for verification)
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'employee_profiles';
