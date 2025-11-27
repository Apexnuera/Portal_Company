# ✅ Supabase Setup Checklist

Use this checklist to ensure your Supabase setup is complete and working correctly.

## 📦 Prerequisites

- [ ] Supabase account created at [supabase.com](https://supabase.com)
- [ ] Flutter SDK installed (version 3.9.2+)
- [ ] Project dependencies installed (`flutter pub get`)

---

## 🔧 Supabase Project Configuration

### 1. Create Supabase Project
- [ ] Created new project in Supabase dashboard
- [ ] Project is fully provisioned (green status indicator)
- [ ] Noted down database password

### 2. Get API Credentials
- [ ] Copied **Project URL** from Settings → API
- [ ] Copied **anon/public key** from Settings → API
- [ ] Updated `lib/config/supabase_config.dart` with these values

### 3. Database Setup
- [ ] Opened SQL Editor in Supabase dashboard
- [ ] Ran `supabase_complete_setup.sql` script
- [ ] Verified tables created: `user_roles`, `employee_profiles`
- [ ] Verified RLS policies are enabled
- [ ] No errors in SQL execution

---

## 👥 User Creation

### 1. Create Test Users in Auth UI
Go to **Authentication** → **Users** → **Add User**

#### HR User
- [ ] Email: `hr@apexnuera.com` (or your choice)
- [ ] Password: Set a strong password (save it!)
- [ ] Auto Confirm User: ✅ **CHECKED**
- [ ] User created successfully

#### Employee User
- [ ] Email: `employee@apexnuera.com` (or your choice)
- [ ] Password: Set a strong password (save it!)
- [ ] Auto Confirm User: ✅ **CHECKED**
- [ ] User created successfully

### 2. Assign Roles to Users
- [ ] Opened SQL Editor
- [ ] Ran `supabase_quick_start.sql` script
- [ ] Verified roles assigned (run verification query)
- [ ] No errors in role assignment

### 3. Verify User Setup
Run this query in SQL Editor:
```sql
SELECT u.email, ur.role, ur.created_at
FROM auth.users u
LEFT JOIN user_roles ur ON u.id = ur.id;
```

- [ ] HR user shows role: `hr`
- [ ] Employee user shows role: `employee`
- [ ] All users have a role assigned

---

## 🔐 Security Configuration

### Row Level Security (RLS)
- [ ] RLS enabled on `user_roles` table
- [ ] RLS enabled on `employee_profiles` table
- [ ] Policies created for user access
- [ ] Policies created for HR access

### Email Settings (Optional)
- [ ] Email confirmation enabled/disabled as needed
- [ ] Email templates customized (optional)
- [ ] Password reset flow tested (optional)

---

## 📱 Flutter App Configuration

### 1. Code Configuration
- [ ] `lib/config/supabase_config.dart` updated with credentials
- [ ] `supabaseUrl` is correct
- [ ] `supabaseAnonKey` is correct
- [ ] No placeholder values remain

### 2. Dependencies
- [ ] Ran `flutter pub get`
- [ ] No dependency errors
- [ ] `supabase_flutter: ^2.8.0` installed

### 3. Build and Run
- [ ] App builds without errors
- [ ] No Supabase initialization errors in console
- [ ] App launches successfully

---

## 🧪 Testing

### Test HR Login Flow
1. [ ] Navigate to homepage
2. [ ] Click "Login" → "HR Login"
3. [ ] Enter HR credentials
4. [ ] Click "Login"
5. [ ] **Expected**: Redirected to `/hr/dashboard`
6. [ ] **Expected**: HR dashboard loads successfully
7. [ ] **Expected**: Can see HR-specific features

### Test Employee Login Flow
1. [ ] Navigate to homepage
2. [ ] Click "Login" → "Employee Login"
3. [ ] Enter Employee credentials
4. [ ] Click "Login"
5. [ ] **Expected**: Redirected to `/employee/dashboard`
6. [ ] **Expected**: Employee dashboard loads successfully
7. [ ] **Expected**: Can see Employee-specific features

### Test Role-Based Access Control
1. [ ] Try HR credentials on Employee login page
   - **Expected**: "Access denied. This account is not authorized for employee access."
2. [ ] Try Employee credentials on HR login page
   - **Expected**: "Access denied. This account is not authorized for HR access."
3. [ ] Try accessing `/hr/dashboard` without login
   - **Expected**: Redirected to `/login/hr`
4. [ ] Try accessing `/employee/dashboard` without login
   - **Expected**: Redirected to `/login/employee`

### Test Logout Flow
1. [ ] Login as HR user
2. [ ] Click logout button
3. [ ] **Expected**: Redirected to homepage
4. [ ] **Expected**: Cannot access `/hr/dashboard` anymore
5. [ ] Repeat for Employee user

### Test Invalid Credentials
1. [ ] Try login with wrong password
   - **Expected**: Error message displayed
2. [ ] Try login with non-existent email
   - **Expected**: Error message displayed
3. [ ] Try login with empty fields
   - **Expected**: Validation errors shown

---

## 🐛 Troubleshooting

### Common Issues

#### ❌ "Invalid login credentials"
- [ ] Verified email and password are correct
- [ ] Checked user exists in Auth UI
- [ ] Verified "Auto Confirm User" was checked

#### ❌ "Access denied" message
- [ ] Verified user has role in `user_roles` table
- [ ] Ran verification query to check role
- [ ] Re-ran `supabase_quick_start.sql` if needed

#### ❌ "Error fetching user role"
- [ ] Checked RLS policies on `user_roles` table
- [ ] Verified policies allow authenticated users to read
- [ ] Re-ran `supabase_complete_setup.sql`

#### ❌ App crashes on startup
- [ ] Verified Supabase credentials are correct
- [ ] Checked console for error messages
- [ ] Verified `SupabaseConfig.initialize()` is called in `main()`

#### ❌ Dashboard doesn't load
- [ ] Checked browser console for errors
- [ ] Verified user is authenticated
- [ ] Checked GoRouter configuration in `main.dart`

---

## 📊 Verification Queries

Run these in Supabase SQL Editor to verify setup:

### Check all users and roles
```sql
SELECT 
  u.email,
  ur.role,
  ep.full_name,
  ep.employee_id,
  u.created_at
FROM auth.users u
LEFT JOIN user_roles ur ON u.id = ur.id
LEFT JOIN employee_profiles ep ON u.id = ep.id
ORDER BY u.created_at DESC;
```

### Check RLS policies
```sql
SELECT tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename IN ('user_roles', 'employee_profiles');
```

### Check table structure
```sql
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name IN ('user_roles', 'employee_profiles')
ORDER BY table_name, ordinal_position;
```

---

## ✅ Final Verification

- [ ] HR users can login and access HR dashboard
- [ ] Employee users can login and access Employee dashboard
- [ ] Role-based access control is working
- [ ] Users cannot access unauthorized routes
- [ ] Logout functionality works
- [ ] No console errors during normal operation
- [ ] All test cases pass

---

## 🎉 Setup Complete!

If all items are checked, your Supabase authentication is fully configured and working!

### Next Steps:
1. [ ] Add more test users as needed
2. [ ] Configure employee profiles
3. [ ] Set up additional features (timesheets, compensation, etc.)
4. [ ] Customize email templates
5. [ ] Deploy to production

---

## 📝 Notes

**Test Credentials:**
- HR: `hr@apexnuera.com` / (your password)
- Employee: `employee@apexnuera.com` / (your password)

**Important Files:**
- Configuration: `lib/config/supabase_config.dart`
- Auth Service: `lib/services/auth_service.dart`
- HR Login: `lib/hr_login_page.dart`
- Employee Login: `lib/employee_login_page.dart`
- Main Router: `lib/main.dart`

**Supabase Dashboard:**
- Project URL: (your project URL)
- Dashboard: https://app.supabase.com

---

**Last Updated**: November 2025
