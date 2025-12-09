# Fix for Infinite Recursion Error in Supabase RLS Policies

## Problem
You're experiencing this error:
```
PostgrestException(message: infinite recursion detected in policy for relation "user_roles", code: 42P17)
```

## Root Cause
The RLS policy on `user_roles` table was creating a circular dependency:
- When querying `user_roles`, the policy checked if the user is HR
- To check if user is HR, it queried `user_roles` again
- This created an infinite loop

## Solution
Use a **SECURITY DEFINER** function that bypasses RLS to break the circular dependency.

## Steps to Fix

### ⭐ RECOMMENDED: Run the Comprehensive Fix (Easiest)
**File:** `APPLY_THIS_FIX.sql`

This single script fixes EVERYTHING:
- ✅ Creates the `is_hr_user()` security definer function
- ✅ Fixes all `user_roles` policies (stops infinite recursion)
- ✅ Updates all `jobs` table policies
- ✅ Updates all `internships` table policies
- ✅ Updates all `job_applications` table policies
- ✅ Updates all `internship_applications` table policies
- ✅ Updates all `employees` table policies
- ✅ Adds missing `reference_code` columns
- ✅ Includes verification queries

**How to use:**
1. Open your Supabase Dashboard
2. Go to SQL Editor
3. Copy and paste the entire contents of `APPLY_THIS_FIX.sql`
4. Click "Run"
5. Done! ✨

### Alternative Options

#### Option 2: Run Only the RLS Fix
If you only want to fix the recursion issue:
**File:** `supabase_rls_fix.sql`

#### Option 3: Run the Complete Fix (Jobs + RLS)
If you want to fix jobs table AND recursion:
**File:** `supabase_complete_fix.sql`

#### Option 4: Full Setup (For New Installations)
If setting up employees table from scratch:
1. First run: `supabase_rls_fix.sql` (creates the `is_hr_user` function)
2. Then run: `supabase_employees_setup.sql` (creates employees table with correct policies)

## What Changed

### Before (Caused Infinite Recursion):
```sql
CREATE POLICY "HR can read all roles" ON user_roles
  FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM user_roles WHERE id = auth.uid() AND role = 'hr')
    -- ⬆️ This queries user_roles, which triggers the same policy again!
  );
```

### After (Fixed):
```sql
-- Security definer function bypasses RLS
CREATE OR REPLACE FUNCTION is_hr_user(user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER  -- ⬅️ This is the key - bypasses RLS
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_roles
    WHERE id = user_id AND role = 'hr'
  );
END;
$$;

-- Policy now uses the function
CREATE POLICY "HR can read all roles" ON user_roles
  FOR SELECT
  USING (is_hr_user(auth.uid()));  -- ⬅️ No recursion!
```

## Verification

After running the fix, test by:
1. Logging in as an HR user
2. Try to fetch user roles:
   ```dart
   final response = await supabase
     .from('user_roles')
     .select('role')
     .eq('id', userId)
     .single();
   ```
3. Should work without the infinite recursion error

## Additional Benefits

The updated policies now also allow HR users to:
- Insert new user roles (when creating employees)
- Update existing user roles
- Delete user roles

All using the same `is_hr_user()` function to prevent recursion.

## Files Modified
1. ✅ `supabase_complete_fix.sql` - Updated with security definer function
2. ✅ `supabase_rls_fix.sql` - New file with standalone RLS fix
3. ✅ `supabase_employees_setup.sql` - Updated to use `is_hr_user()` function

## Next Steps
1. Open Supabase SQL Editor
2. Run `supabase_complete_fix.sql`
3. Test your application
4. The error should be resolved! ✨
