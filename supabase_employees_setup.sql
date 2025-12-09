-- Supabase Employees Table Setup
-- Run this script in your Supabase SQL Editor after running supabase_setup.sql

-- Create employees table to store employee data
CREATE TABLE IF NOT EXISTS employees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  employee_id TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Enable Row Level Security (RLS)
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (for re-running script)
DROP POLICY IF EXISTS "HR can insert employees" ON employees;
DROP POLICY IF EXISTS "HR can select employees" ON employees;
DROP POLICY IF EXISTS "HR can update employees" ON employees;
DROP POLICY IF EXISTS "HR can delete employees" ON employees;
DROP POLICY IF EXISTS "Employees can read own data" ON employees;

-- Policy: HR can SELECT all employees
CREATE POLICY "HR can select employees"
  ON employees
  FOR SELECT
  USING (is_hr_user(auth.uid()));

-- Policy: HR can INSERT employees
CREATE POLICY "HR can insert employees"
  ON employees
  FOR INSERT
  WITH CHECK (is_hr_user(auth.uid()));

-- Policy: HR can UPDATE employees
CREATE POLICY "HR can update employees"
  ON employees
  FOR UPDATE
  USING (is_hr_user(auth.uid()))
  WITH CHECK (is_hr_user(auth.uid()));

-- Policy: HR can DELETE employees
CREATE POLICY "HR can delete employees"
  ON employees
  FOR DELETE
  USING (is_hr_user(auth.uid()));

-- Policy: Employees can read their own data
CREATE POLICY "Employees can read own data"
  ON employees
  FOR SELECT
  USING (auth.uid() = auth_user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS employees_auth_user_id_idx ON employees(auth_user_id);
CREATE INDEX IF NOT EXISTS employees_employee_id_idx ON employees(employee_id);
CREATE INDEX IF NOT EXISTS employees_email_idx ON employees(email);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_employees_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
CREATE TRIGGER update_employees_updated_at_trigger
  BEFORE UPDATE ON employees
  FOR EACH ROW
  EXECUTE FUNCTION update_employees_updated_at();

-- Grant necessary permissions (Supabase handles this automatically, but explicit for clarity)
-- GRANT SELECT ON employees TO authenticated;
