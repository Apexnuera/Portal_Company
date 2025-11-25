-- Quick RLS Policy Setup for Employees Table
-- If you've already created the employees table, run this to add RLS policies

-- Enable RLS if not already enabled
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "HR can insert employees" ON employees;
DROP POLICY IF EXISTS "HR can select employees" ON employees;
DROP POLICY IF EXISTS "HR can update employees" ON employees;
DROP POLICY IF EXISTS "HR can delete employees" ON employees;
DROP POLICY IF EXISTS "Employees can read own data" ON employees;

-- Create policies for HR users

-- HR can SELECT all employees
CREATE POLICY "HR can select employees"
  ON employees
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- HR can INSERT employees
CREATE POLICY "HR can insert employees"
  ON employees
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- HR can UPDATE employees
CREATE POLICY "HR can update employees"
  ON employees
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- HR can DELETE employees
CREATE POLICY "HR can delete employees"
  ON employees
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.id = auth.uid()
      AND user_roles.role = 'hr'
    )
  );

-- Employees can read their own data
CREATE POLICY "Employees can read own data"
  ON employees
  FOR SELECT
  USING (auth.uid() = auth_user_id);

-- Verify policies were created
-- Run this to check:
-- SELECT * FROM pg_policies WHERE tablename = 'employees';
