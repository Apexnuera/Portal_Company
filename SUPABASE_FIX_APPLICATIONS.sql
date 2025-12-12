-- Fix Permission Denied Error for Job/Internship Applications
-- The issue is that RLS policies are querying auth.users which requires special permissions

-- Drop the problematic policies that query auth.users
DROP POLICY IF EXISTS "Applicant can read own job application" ON job_applications;
DROP POLICY IF EXISTS "Applicant can read own internship application" ON internship_applications;

-- Recreate policies using auth.jwt() instead of querying auth.users
-- This gets the email from the JWT token directly, no table access needed

-- For Job Applications - allow applicants to read their own submissions
CREATE POLICY "Applicant can read own job application" ON job_applications 
FOR SELECT USING (
  email = (auth.jwt() ->> 'email')
);

-- For Internship Applications - allow applicants to read their own submissions
CREATE POLICY "Applicant can read own internship application" ON internship_applications 
FOR SELECT USING (
  email = (auth.jwt() ->> 'email')
);

-- Also ensure the is_hr_user function doesn't cause permission issues
-- Recreate it to be security definer (runs with elevated privileges)
CREATE OR REPLACE FUNCTION is_hr_user(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_roles 
    WHERE user_roles.user_id = $1 
    AND role = 'hr'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Reload schema cache
NOTIFY pgrst, 'reload schema';
