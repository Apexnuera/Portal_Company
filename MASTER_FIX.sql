-- ==============================================================================
-- MASTER FIX SCRIPT: RUN THIS TO FIX ALL PERMISSION AND LOGIN ISSUES
-- ==============================================================================

-- PART 1: FIX RLS PERMISSION ERROR (Recursion Bug)
-- This fixes "new row violates row-level security policy for table user_roles"

-- Create a secure function to check HR role (bypasses RLS)
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

-- Drop existing problematic policies
DROP POLICY IF EXISTS "HR can assign employee roles" ON user_roles;
DROP POLICY IF EXISTS "HR can view all roles" ON user_roles;
DROP POLICY IF EXISTS "HR can update employee roles" ON user_roles;
DROP POLICY IF EXISTS "HR can delete employee roles" ON user_roles;
DROP POLICY IF EXISTS "Users can read their own role" ON user_roles;
DROP POLICY IF EXISTS "Service role can manage user roles" ON user_roles;

-- Re-create policies using the secure function
CREATE POLICY "Users can read their own role" ON user_roles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Service role can manage user roles" ON user_roles FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');
CREATE POLICY "HR can view all roles" ON user_roles FOR SELECT USING (is_hr());

-- The critical policy for creating employees:
CREATE POLICY "HR can assign employee roles" ON user_roles FOR INSERT
WITH CHECK (
  is_hr() 
  AND role = 'employee'
);

CREATE POLICY "HR can update employee roles" ON user_roles FOR UPDATE USING (is_hr()) WITH CHECK (role = 'employee');
CREATE POLICY "HR can delete employee roles" ON user_roles FOR DELETE USING (is_hr() AND role = 'employee');

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.is_hr() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_hr() TO anon;


-- PART 2: AUTO-CONFIRM EMAILS FOR HR-CREATED EMPLOYEES
-- This fixes the "Email not confirmed" login error

-- Create trigger function
CREATE OR REPLACE FUNCTION public.auto_confirm_hr_created_users()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the user has the 'is_hr_created' metadata flag
  IF NEW.raw_user_meta_data->>'is_hr_created' = 'true' THEN
    NEW.email_confirmed_at = now();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Re-create trigger
DROP TRIGGER IF EXISTS on_auth_user_created_auto_confirm ON auth.users;

CREATE TRIGGER on_auth_user_created_auto_confirm
  BEFORE INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_confirm_hr_created_users();


-- PART 3: CLEANUP (Optional)
-- Clean up any broken state if needed
-- (Safe to run)
