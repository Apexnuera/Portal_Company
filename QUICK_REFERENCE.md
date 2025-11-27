# 🎯 Supabase Setup - Quick Reference Card

## 📋 Setup Steps (Copy & Paste)

### 1️⃣ Create Supabase Project
```
1. Go to: https://app.supabase.com
2. Click: "New Project"
3. Name: ApexNuera Portal
4. Region: (choose closest)
5. Password: (save this!)
6. Click: "Create new project"
7. Wait: 2-3 minutes
```

### 2️⃣ Get API Credentials
```
1. Go to: Settings → API
2. Copy: Project URL
3. Copy: anon/public key
4. Update: lib/config/supabase_config.dart
```

**Update this file:**
```dart
// lib/config/supabase_config.dart
static const String supabaseUrl = 'PASTE_PROJECT_URL_HERE';
static const String supabaseAnonKey = 'PASTE_ANON_KEY_HERE';
```

### 3️⃣ Run Database Setup
```
1. Open: Supabase SQL Editor
2. Copy: supabase_complete_setup.sql
3. Paste and Run: Ctrl+Enter
4. Verify: No errors
```

### 4️⃣ Create Test Users
```
1. Go to: Authentication → Users
2. Click: "Add User"
3. Create HR user:
   - Email: hr@apexnuera.com
   - Password: (your choice)
   - ✅ Auto Confirm User
4. Create Employee user:
   - Email: employee@apexnuera.com
   - Password: (your choice)
   - ✅ Auto Confirm User
```

### 5️⃣ Assign Roles
```
1. Open: Supabase SQL Editor
2. Copy: supabase_quick_start.sql
3. Paste and Run: Ctrl+Enter
4. Verify: Run verification query
```

**Verification Query:**
```sql
SELECT u.email, ur.role 
FROM auth.users u
LEFT JOIN user_roles ur ON u.id = ur.id;
```

### 6️⃣ Run the App
```bash
flutter pub get
flutter run -d chrome
```

### 7️⃣ Test Login
```
HR Login:
  URL: /login/hr
  Email: hr@apexnuera.com
  Password: (your password)
  Expected: Redirect to /hr/dashboard

Employee Login:
  URL: /login/employee
  Email: employee@apexnuera.com
  Password: (your password)
  Expected: Redirect to /employee/dashboard
```

---

## 🗂️ File Locations

| What | Where |
|------|-------|
| **Supabase Config** | `lib/config/supabase_config.dart` |
| **Auth Service** | `lib/services/auth_service.dart` |
| **HR Login** | `lib/hr_login_page.dart` |
| **Employee Login** | `lib/employee_login_page.dart` |
| **HR Dashboard** | `lib/pages/hr_dashboard_page.dart` |
| **Employee Dashboard** | `lib/pages/employee_dashboard_page.dart` |
| **Main Router** | `lib/main.dart` |
| **Complete Setup SQL** | `supabase_complete_setup.sql` |
| **Quick Start SQL** | `supabase_quick_start.sql` |

---

## 🔑 Important URLs

| Service | URL |
|---------|-----|
| **Supabase Dashboard** | https://app.supabase.com |
| **Your Project** | https://app.supabase.com/project/YOUR_PROJECT_ID |
| **SQL Editor** | Dashboard → SQL Editor |
| **Auth Users** | Dashboard → Authentication → Users |
| **Database Tables** | Dashboard → Table Editor |
| **API Settings** | Dashboard → Settings → API |

---

## 📊 Database Tables

### user_roles
```sql
CREATE TABLE user_roles (
  id UUID PRIMARY KEY,           -- References auth.users.id
  role TEXT NOT NULL,            -- 'hr' or 'employee'
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
```

### employee_profiles
```sql
CREATE TABLE employee_profiles (
  id UUID PRIMARY KEY,           -- References auth.users.id
  email TEXT NOT NULL,
  full_name TEXT,
  employee_id TEXT UNIQUE,
  department TEXT,
  position TEXT,
  phone TEXT,
  date_of_birth DATE,
  date_of_joining DATE,
  -- ... more fields
);
```

---

## 🔐 Security Policies (RLS)

### user_roles
- ✅ Users can read their own role
- ✅ Authenticated users can read all roles
- ✅ Only service role can modify roles

### employee_profiles
- ✅ Users can read their own profile
- ✅ HR can read all profiles
- ✅ HR can manage all profiles

---

## 🎯 Quick SQL Commands

### View all users with roles
```sql
SELECT u.email, ur.role, ep.full_name, ep.employee_id
FROM auth.users u
LEFT JOIN user_roles ur ON u.id = ur.id
LEFT JOIN employee_profiles ep ON u.id = ep.id
ORDER BY ur.role, u.email;
```

### Assign HR role
```sql
INSERT INTO user_roles (id, role, email)
SELECT id, 'hr', email 
FROM auth.users 
WHERE email = 'hr@example.com'
ON CONFLICT (id) DO UPDATE SET role = 'hr';
```

### Assign Employee role
```sql
INSERT INTO user_roles (id, role, email)
SELECT id, 'employee', email 
FROM auth.users 
WHERE email = 'employee@example.com'
ON CONFLICT (id) DO UPDATE SET role = 'employee';
```

### Update user role
```sql
UPDATE user_roles 
SET role = 'hr' 
WHERE email = 'user@example.com';
```

### Delete user role
```sql
DELETE FROM user_roles 
WHERE email = 'user@example.com';
```

### Get user ID by email
```sql
SELECT id, email 
FROM auth.users 
WHERE email = 'user@example.com';
```

---

## 🧪 Test Cases

| Test | Steps | Expected Result |
|------|-------|-----------------|
| **HR Login** | 1. Go to /login/hr<br>2. Enter HR credentials<br>3. Click Login | Redirect to /hr/dashboard |
| **Employee Login** | 1. Go to /login/employee<br>2. Enter Employee credentials<br>3. Click Login | Redirect to /employee/dashboard |
| **Wrong Role (HR)** | 1. Go to /login/employee<br>2. Enter HR credentials<br>3. Click Login | Error: "Access denied..." |
| **Wrong Role (Emp)** | 1. Go to /login/hr<br>2. Enter Employee credentials<br>3. Click Login | Error: "Access denied..." |
| **Invalid Password** | 1. Go to any login page<br>2. Enter wrong password<br>3. Click Login | Error: "Invalid credentials" |
| **Protected Route** | 1. Go to /hr/dashboard (not logged in) | Redirect to /login/hr |
| **Logout** | 1. Login as any user<br>2. Click Logout | Redirect to homepage |

---

## 🐛 Troubleshooting Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| **Invalid credentials** | Check user exists in Auth UI, verify password |
| **Access denied** | Run: `SELECT * FROM user_roles WHERE email = 'user@email.com'` |
| **Error fetching role** | Re-run `supabase_complete_setup.sql` |
| **App crashes** | Verify credentials in `supabase_config.dart` |
| **Can't access dashboard** | Check if logged in, verify role |
| **Table doesn't exist** | Run `supabase_complete_setup.sql` |
| **RLS error** | Check policies in Table Editor → RLS |

---

## 📱 Flutter Commands

```bash
# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on macOS
flutter run -d macos

# Run on Windows
flutter run -d windows

# Clean build
flutter clean

# Clean and reinstall
flutter clean && flutter pub get

# Build for web
flutter build web

# Check for issues
flutter doctor
```

---

## 🔧 Configuration Checklist

- [ ] Supabase project created
- [ ] API credentials copied
- [ ] `supabase_config.dart` updated
- [ ] `supabase_complete_setup.sql` executed
- [ ] Tables created (user_roles, employee_profiles)
- [ ] RLS policies enabled
- [ ] HR user created in Auth UI
- [ ] Employee user created in Auth UI
- [ ] Roles assigned via `supabase_quick_start.sql`
- [ ] `flutter pub get` executed
- [ ] App runs without errors
- [ ] HR login tested
- [ ] Employee login tested
- [ ] Role-based access tested

---

## 📞 Support Resources

| Resource | Link |
|----------|------|
| **Detailed Setup Guide** | [SUPABASE_SETUP_GUIDE.md](SUPABASE_SETUP_GUIDE.md) |
| **Setup Checklist** | [SUPABASE_CHECKLIST.md](SUPABASE_CHECKLIST.md) |
| **Authentication Flow** | [AUTHENTICATION_FLOW.md](AUTHENTICATION_FLOW.md) |
| **Summary** | [SUPABASE_SUMMARY.md](SUPABASE_SUMMARY.md) |
| **Quick Start** | [README_SUPABASE.md](README_SUPABASE.md) |
| **Supabase Docs** | https://supabase.com/docs |
| **Flutter Docs** | https://flutter.dev/docs |

---

## 🎯 Success Criteria

✅ **Setup is complete when:**
- HR user can login and access HR dashboard
- Employee user can login and access Employee dashboard
- HR credentials are rejected on employee login
- Employee credentials are rejected on HR login
- Protected routes redirect to login
- No console errors during normal operation

---

## 💾 Backup Important Info

**Save these somewhere safe:**

```
Supabase Project URL: _______________________________
Supabase Anon Key: ___________________________________
Database Password: ___________________________________
HR Test Email: _______________________________________
HR Test Password: ____________________________________
Employee Test Email: _________________________________
Employee Test Password: ______________________________
```

---

## ⏱️ Time Estimates

| Task | Time |
|------|------|
| Create Supabase project | 5 min |
| Update config | 2 min |
| Run SQL scripts | 3 min |
| Create test users | 4 min |
| Test app | 3 min |
| **Total** | **~15-20 min** |

---

## 🎉 You're All Set!

Print this card and keep it handy for quick reference during setup!

**Last Updated**: November 2025
