# 🚨 QUICK FIX GUIDE - Infinite Recursion Error

## Your Error
```
PostgrestException(message: infinite recursion detected in policy for relation "user_roles", code: 42P17)
```

## ⚡ FASTEST FIX (Do This Now!)

### Step 1: Open Supabase
1. Go to your Supabase Dashboard
2. Click on "SQL Editor" in the left sidebar

### Step 2: Run the Fix
1. Open the file: **`MINIMAL_FIX.sql`** (in your project folder)
2. Copy ALL the contents
3. Paste into Supabase SQL Editor
4. Click the **"Run"** button

### Step 3: Test
1. Refresh your Flutter app
2. Try logging in as HR user
3. The error should be GONE! ✅

---

## 🔧 Alternative: Full Fix (Updates All Tables)

If you want to update ALL your table policies at once:

1. Use **`APPLY_THIS_FIX_V2.sql`** instead
2. This safely updates policies for all tables (jobs, internships, applications, etc.)
3. It automatically skips tables that don't exist yet

---

## 📊 What This Fixes

| Issue | Status |
|-------|--------|
| Infinite recursion in user_roles | ✅ Fixed |
| HR policies on jobs table | ✅ Fixed |
| HR policies on internships table | ✅ Fixed |
| HR policies on applications tables | ✅ Fixed |
| HR policies on employees table | ✅ Fixed |
| Missing reference_code columns | ✅ Fixed |

---

## 🔍 Technical Details (Optional Reading)

### The Problem
Your RLS policy was checking `user_roles` table while creating a policy ON the `user_roles` table:

```sql
-- ❌ BAD - Creates infinite loop
CREATE POLICY "HR can read all roles" ON user_roles
  USING (
    EXISTS (SELECT 1 FROM user_roles WHERE ...) -- Queries same table!
  );
```

### The Solution
Use a SECURITY DEFINER function that bypasses RLS:

```sql
-- ✅ GOOD - Function bypasses RLS
CREATE FUNCTION is_hr_user(user_id UUID)
RETURNS BOOLEAN
SECURITY DEFINER  -- This is the magic!
AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM user_roles WHERE id = user_id AND role = 'hr');
END;
$$;

-- Now the policy doesn't cause recursion
CREATE POLICY "HR can read all roles" ON user_roles
  USING (is_hr_user(auth.uid()));
```

---

## 📁 Files Updated

All these files have been updated with the fix:
- ✅ `APPLY_THIS_FIX.sql` - **USE THIS ONE** (comprehensive fix)
- ✅ `supabase_complete_fix.sql` - Updated with security definer function
- ✅ `supabase_rls_fix.sql` - Standalone RLS fix
- ✅ `supabase_employees_setup.sql` - Updated employee policies
- ✅ `supabase_jobs_schema.sql` - Updated job/internship policies
- ✅ `RLS_FIX_README.md` - Detailed documentation

---

## ❓ Still Having Issues?

If the error persists after running the fix:

1. **Check the function exists:**
   ```sql
   SELECT * FROM pg_proc WHERE proname = 'is_hr_user';
   ```

2. **Check your policies:**
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'user_roles';
   ```

3. **Verify your user has HR role:**
   ```sql
   SELECT * FROM user_roles WHERE id = auth.uid();
   ```

---

## 🎯 Summary

**Problem:** Circular dependency in RLS policies  
**Solution:** Security definer function  
**Action:** Run `APPLY_THIS_FIX.sql` in Supabase SQL Editor  
**Result:** No more infinite recursion! 🎉
