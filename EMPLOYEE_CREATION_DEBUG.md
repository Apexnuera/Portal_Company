# Employee Creation Debugging Guide

If employees are not being created in the Supabase table, follow these debugging steps:

## 1. Check Browser Console (CRITICAL)

When you click "Create Employee", check the browser developer console (F12) for errors:

**Chrome/Edge:** Press `F12` → **Console** tab
**Watch for:**
- Red error messages
- `debugPrint` messages showing what's happening
- Supabase error messages

## 2. Verify Supabase Setup

### A. Check Tables Exist
1. Go to Supabase Dashboard → **Table Editor**
2. Verify these tables exist:
   - ✅ `user_roles` (from supabase_setup.sql)
   - ✅ `employees` (from supabase_employees_setup.sql)

### B. Check RLS Policies
1. Click on `employees` table
2. Go to **Policies** or **RLS** tab
3. You should see **5 policies**:
   - HR can select employees
   - HR can insert employees  
   - HR can update employees
   - HR can delete employees
   - Employees can read own data

**If policies are missing:**
- Run [supabase_rls_policies_fix.sql](file:///c:/Company%20Portal/company_portal/supabase_rls_policies_fix.sql) in SQL Editor

### C. Check HR User Has Role
1. Go to **Table Editor** → **user_roles**
2. Find your HR user's row
3. Verify `role` column = `'hr'` (exactly, lowercase)

**If missing:**
```sql
-- Replace YOUR_HR_USER_ID with actual UUID from auth.users
INSERT INTO user_roles (id, role, email)
VALUES ('YOUR_HR_USER_ID', 'hr', 'hr@test.com')
ON CONFLICT (id) DO UPDATE SET role = 'hr';
```

## 3. Test Create Employee Step-by-Step

### Browser Console Commands (For Debugging)

Open browser console and run:

```javascript
// Check if user is authenticated
console.log('Current user:', supabase.auth.getUser());

// Check if HR role is set
console.log('Auth service:', AuthService.instance.userRole);

// Try to INSERT manually
const result = await supabase
  .from('employees')
  .insert({
    auth_user_id: 'test-uuid',
    employee_id: 'TEST001',
    name: 'Test User',
    email: 'test@example.com'
  });
console.log('Manual insert result:', result);
```

## 4. Common Issues & Solutions

### Issue 1: "Permission denied" or "policy" error
**Cause:** RLS policies not set up correctly
**Solution:** 
1. Run `supabase_rls_policies_fix.sql`
2. Verify your HR user has `role = 'hr'` in `user_roles` table

### Issue 2: "Email already in use"
**Cause:** Email exists in Supabase Auth
**Solution:**
- Go to Supabase → **Authentication** → **Users**
- Delete the existing user with that email
- Try creating again

### Issue 3: "Duplicate key" error
**Cause:** Employee ID already exists
**Solution:**
- Use a different employee ID
- OR delete the existing record from `employees` table

### Issue 4: No error, but employee not appearing
**Cause:** Silent failure or RLS blocking SELECT
**Solution:**
1. Check browser console for errors
2. Verify RLS "HR can select employees" policy exists
3. Check **Table Editor** → **employees** to see if row exists

### Issue 5: Auth user created but no employee record
**Cause:** User created successfully but employee insert failed
**Solution:**
1. Check **Authentication** → **Users** - user will exist
2. Check browser console for the specific error
3. Usually RLS policy issue - run `supabase_rls_policies_fix.sql`

## 5. Enable Detailed Logging

Modify `employee_management_service.dart` temporarily to see more details:

```dart
// In createEmployee method, add more logging:
debugPrint('=== Starting employee creation ===');
debugPrint('Employee ID: $employeeId');
debugPrint('Email: $email');
debugPrint('Current user: ${SupabaseConfig.client.auth.currentUser?.email}');
debugPrint('User role: ${AuthService.instance.userRole}');

// After each step:
debugPrint('Auth user created: ${authResponse.user?.id}');
debugPrint('About to insert role...');
// ... etc
```

## 6. Manual Verification

After attempting to create an employee, check:

### A. Authentication
Supabase Dashboard → **Authentication** → **Users**
- New user should appear with the email
- Status should be "Confirmed"

### B. User Roles
Supabase Dashboard → **Table Editor** → **user_roles**
- Row should exist with the new user's ID
- Role should be 'employee'

### C. Employees Table
Supabase Dashboard → **Table Editor** → **employees**  
- Row should exist with the employee data
- `auth_user_id` should match the user ID from auth.users

## 7. Quick Test Query

Run this in Supabase SQL Editor to see what RLS allows:

```sql
-- Check what policies are active
SELECT * FROM pg_policies WHERE schemaname = 'public' AND tablename = 'employees';

-- Try to select employees (as your logged-in user)
SELECT * FROM employees;

-- Check if HR role is set
SELECT * FROM user_roles WHERE id = auth.uid();
```

## 8. Nuclear Option: Reset Everything

If nothing works, reset the employees setup:

```sql
-- Drop everything
DROP TABLE IF EXISTS employees CASCADE;
DROP POLICY IF EXISTS "HR can insert employees" ON employees;
DROP POLICY IF EXISTS "HR can select employees" ON employees;
DROP POLICY IF EXISTS "HR can update employees" ON employees;
DROP POLICY IF EXISTS "HR can delete employees" ON employees;
DROP POLICY IF EXISTS "Employees can read own data" ON employees;

-- Then re-run supabase_employees_setup.sql completely
```

## Contact Points

If still stuck, provide:
1. Screenshot of browser console errors
2. Screenshot of `employees` table policies
3. Screenshot of your `user_roles` table showing HR user
4. The exact error message from the red SnackBar
