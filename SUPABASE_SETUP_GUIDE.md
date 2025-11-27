# Supabase Setup Guide for HR and Employee Login

This guide will help you set up Supabase authentication for HR and Employee users to access their respective dashboards.

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Supabase Project Setup](#supabase-project-setup)
3. [Database Configuration](#database-configuration)
4. [Creating Test Users](#creating-test-users)
5. [Flutter App Configuration](#flutter-app-configuration)
6. [Testing the Setup](#testing-the-setup)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- A Supabase account (sign up at [supabase.com](https://supabase.com))
- Flutter SDK installed
- This project cloned and dependencies installed

---

## Supabase Project Setup

### Step 1: Create a New Supabase Project

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Click **"New Project"**
3. Fill in the details:
   - **Name**: `ApexNuera Portal` (or your preferred name)
   - **Database Password**: Choose a strong password (save this!)
   - **Region**: Select the closest region to your users
4. Click **"Create new project"**
5. Wait for the project to be provisioned (2-3 minutes)

### Step 2: Get Your API Credentials

1. In your Supabase project dashboard, go to **Settings** → **API**
2. You'll need two values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)

3. Update `lib/config/supabase_config.dart`:
   ```dart
   static const String supabaseUrl = 'YOUR_PROJECT_URL';
   static const String supabaseAnonKey = 'YOUR_ANON_KEY';
   ```

---

## Database Configuration

### Step 1: Run the Database Setup Script

1. In your Supabase dashboard, go to **SQL Editor**
2. Click **"New query"**
3. Copy and paste the contents of `supabase_setup.sql`
4. Click **"Run"** or press `Ctrl+Enter`

This creates:
- `user_roles` table to store user role assignments (hr/employee)
- Row Level Security (RLS) policies
- Necessary indexes and triggers

### Step 2: Verify Table Creation

1. Go to **Table Editor** in Supabase dashboard
2. You should see a `user_roles` table with columns:
   - `id` (UUID, Primary Key)
   - `role` (TEXT)
   - `email` (TEXT)
   - `created_at` (TIMESTAMPTZ)
   - `updated_at` (TIMESTAMPTZ)

---

## Creating Test Users

### Step 1: Create Users in Supabase Auth

1. Go to **Authentication** → **Users** in your Supabase dashboard
2. Click **"Add user"** → **"Create new user"**
3. Create an HR user:
   - **Email**: `hr@test.com` (or your preferred email)
   - **Password**: Choose a password (minimum 6 characters)
   - **Auto Confirm User**: ✅ Check this box
4. Click **"Create user"**
5. Repeat for an Employee user:
   - **Email**: `employee@test.com`
   - **Password**: Choose a password
   - **Auto Confirm User**: ✅ Check this box

### Step 2: Assign Roles to Users

1. Go to **SQL Editor** in Supabase
2. Click **"New query"**
3. Run this query to get user IDs:
   ```sql
   SELECT id, email FROM auth.users;
   ```
4. Copy the UUIDs for your users
5. Run this query to assign roles (replace the UUIDs with your actual user IDs):
   ```sql
   -- Insert HR role
   INSERT INTO user_roles (id, role, email)
   VALUES ('PASTE_HR_USER_UUID_HERE', 'hr', 'hr@test.com');

   -- Insert Employee role
   INSERT INTO user_roles (id, role, email)
   VALUES ('PASTE_EMPLOYEE_USER_UUID_HERE', 'employee', 'employee@test.com');
   ```

### Alternative: Create Users Programmatically

You can also use the Supabase dashboard's SQL editor to create users and assign roles in one go:

```sql
-- This is a helper script - you'll need to manually create users via Auth UI first
-- Then run this to assign roles

-- Example: After creating users, assign roles
INSERT INTO user_roles (id, role, email)
SELECT id, 'hr', email 
FROM auth.users 
WHERE email = 'hr@test.com'
ON CONFLICT (id) DO UPDATE SET role = 'hr';

INSERT INTO user_roles (id, role, email)
SELECT id, 'employee', email 
FROM auth.users 
WHERE email = 'employee@test.com'
ON CONFLICT (id) DO UPDATE SET role = 'employee';
```

---

## Flutter App Configuration

### Step 1: Verify Dependencies

Ensure `pubspec.yaml` has:
```yaml
dependencies:
  supabase_flutter: ^2.8.0
  go_router: ^17.0.0
  provider: ^6.1.2
```

Run:
```bash
flutter pub get
```

### Step 2: Update Supabase Config

Edit `lib/config/supabase_config.dart` with your credentials:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
```

### Step 3: Run the App

```bash
flutter run -d chrome
```

Or for other platforms:
```bash
flutter run -d macos
flutter run -d windows
flutter run -d linux
```

---

## Testing the Setup

### Test HR Login

1. Navigate to the app homepage
2. Click **"Login"** → **"HR Login"**
3. Enter credentials:
   - Email: `hr@test.com`
   - Password: (the password you set)
4. Click **"Login"**
5. You should be redirected to `/hr/dashboard`

### Test Employee Login

1. Navigate to the app homepage
2. Click **"Login"** → **"Employee Login"**
3. Enter credentials:
   - Email: `employee@test.com`
   - Password: (the password you set)
4. Click **"Login"**
5. You should be redirected to `/employee/dashboard`

### Test Role-Based Access Control

1. Try logging in with HR credentials on the Employee login page
   - ✅ Should show: "Access denied. This account is not authorized for employee access."
2. Try logging in with Employee credentials on the HR login page
   - ✅ Should show: "Access denied. This account is not authorized for HR access."

---

## Troubleshooting

### Issue: "Invalid login credentials"

**Solution:**
- Verify the email and password are correct
- Check that the user exists in **Authentication** → **Users**
- Ensure **Auto Confirm User** was checked when creating the user

### Issue: "Access denied" message

**Solution:**
- Verify the user has a role assigned in the `user_roles` table
- Run this query to check:
  ```sql
  SELECT * FROM user_roles WHERE email = 'your@email.com';
  ```
- If no role exists, assign one using the SQL from Step 2 above

### Issue: "Error fetching user role"

**Solution:**
- Check Row Level Security (RLS) policies on `user_roles` table
- Verify the policies allow authenticated users to read their own role
- Re-run the `supabase_setup.sql` script

### Issue: App crashes on startup

**Solution:**
- Verify Supabase credentials in `lib/config/supabase_config.dart`
- Check that `SupabaseConfig.initialize()` is called in `main()`
- Look for errors in the console/terminal

### Issue: Users can't see their dashboard

**Solution:**
- Check the GoRouter configuration in `lib/main.dart`
- Verify the redirect logic is working:
  ```dart
  redirect: (context, state) {
    final goingToHR = state.matchedLocation.startsWith('/hr');
    if (goingToHR && !AuthService.instance.isHRLoggedIn) {
      return '/login/hr';
    }
    // ... employee check
  }
  ```

---

## Additional Configuration

### Email Confirmation (Optional)

By default, test users are auto-confirmed. For production:

1. Go to **Authentication** → **Settings** → **Email Auth**
2. Configure email templates
3. Enable email confirmation
4. Users will receive a confirmation email before they can log in

### Password Reset

The app includes a "Forgot Password?" link that navigates to `/change-password`. To enable password reset emails:

1. Go to **Authentication** → **Settings** → **Email Templates**
2. Customize the "Reset Password" template
3. Users will receive reset links via email

### Custom Email Templates

Customize email templates in **Authentication** → **Email Templates**:
- Confirmation email
- Magic link
- Password reset
- Email change

---

## Security Best Practices

1. **Never commit credentials**: Keep `supabase_config.dart` out of version control or use environment variables
2. **Use strong passwords**: Enforce password policies in Supabase settings
3. **Enable MFA**: Consider enabling Multi-Factor Authentication for HR users
4. **Review RLS policies**: Ensure Row Level Security policies are properly configured
5. **Monitor auth logs**: Check **Authentication** → **Logs** for suspicious activity

---

## Next Steps

- ✅ Set up additional employee records in the database
- ✅ Configure employee management features
- ✅ Set up timesheet and compensation services
- ✅ Add more HR administrative features
- ✅ Deploy the app to production

---

## Support

For issues specific to:
- **Supabase**: Check [Supabase Documentation](https://supabase.com/docs)
- **Flutter**: Check [Flutter Documentation](https://flutter.dev/docs)
- **This App**: Review the code in `lib/services/auth_service.dart`

---

## Quick Reference

### Important Files
- `lib/config/supabase_config.dart` - Supabase credentials
- `lib/services/auth_service.dart` - Authentication logic
- `lib/main.dart` - App routing and protected routes
- `lib/hr_login_page.dart` - HR login UI
- `lib/employee_login_page.dart` - Employee login UI
- `lib/pages/hr_dashboard_page.dart` - HR dashboard
- `lib/pages/employee_dashboard_page.dart` - Employee dashboard

### Useful SQL Queries

**Check all users and their roles:**
```sql
SELECT u.email, ur.role, ur.created_at
FROM auth.users u
LEFT JOIN user_roles ur ON u.id = ur.id
ORDER BY ur.created_at DESC;
```

**Add a new role:**
```sql
INSERT INTO user_roles (id, role, email)
VALUES ('user-uuid', 'hr', 'email@example.com');
```

**Update a user's role:**
```sql
UPDATE user_roles 
SET role = 'employee' 
WHERE email = 'user@example.com';
```

**Delete a user's role:**
```sql
DELETE FROM user_roles WHERE email = 'user@example.com';
```

---

**Last Updated**: November 2025
**Version**: 1.0
