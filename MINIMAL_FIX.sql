-- ============================================================================
-- MINIMAL FIX - Only fixes the infinite recursion error
-- ============================================================================
-- Use this if you only want to fix the immediate error and nothing else
-- ============================================================================

-- Step 1: Create the security definer function
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

-- Step 2: Enable RLS on user_roles
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Step 3: Drop existing policies
DROP POLICY IF EXISTS "Users can read own role" ON user_roles;
DROP POLICY IF EXISTS "HR can read all roles" ON user_roles;
DROP POLICY IF EXISTS "Service role can manage roles" ON user_roles;
DROP POLICY IF EXISTS "HR can insert roles" ON user_roles;
DROP POLICY IF EXISTS "HR can update roles" ON user_roles;
DROP POLICY IF EXISTS "HR can delete roles" ON user_roles;

-- Step 4: Create new policies using the security definer function
CREATE POLICY "Users can read own role" ON user_roles
  FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "HR can read all roles" ON user_roles
  FOR SELECT
  USING (is_hr_user(auth.uid()));

CREATE POLICY "HR can insert roles" ON user_roles
  FOR INSERT
  WITH CHECK (is_hr_user(auth.uid()));

CREATE POLICY "HR can update roles" ON user_roles
  FOR UPDATE
  USING (is_hr_user(auth.uid()))
  WITH CHECK (is_hr_user(auth.uid()));

CREATE POLICY "HR can delete roles" ON user_roles
  FOR DELETE
  USING (is_hr_user(auth.uid()));

-- Step 5: Grant permissions
GRANT SELECT ON user_roles TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

-- Verification
SELECT 
  '✅ Infinite recursion fix applied successfully!' as status,
  'The user_roles table policies have been updated.' as details;

-- Show updated policies
SELECT 
  policyname,
  cmd as operation
FROM pg_policies
WHERE tablename = 'user_roles'
ORDER BY policyname;
