# 🚀 Supabase Authentication Setup - Quick Start

This guide will get you up and running with Supabase authentication for HR and Employee users in **under 15 minutes**.

## 📚 Documentation Index

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[SUPABASE_SETUP_GUIDE.md](SUPABASE_SETUP_GUIDE.md)** | Complete step-by-step setup guide | First-time setup, detailed instructions |
| **[SUPABASE_CHECKLIST.md](SUPABASE_CHECKLIST.md)** | Interactive checklist | Verify your setup is complete |
| **[AUTHENTICATION_FLOW.md](AUTHENTICATION_FLOW.md)** | Visual flow diagrams | Understand how auth works |
| **This file (README)** | Quick start guide | Get started fast |

---

## ⚡ Quick Start (15 Minutes)

### Step 1: Supabase Project Setup (5 min)

1. **Create Supabase Project**
   - Go to [app.supabase.com](https://app.supabase.com)
   - Click "New Project"
   - Name: `ApexNuera Portal`
   - Choose region and set password
   - Wait for provisioning

2. **Get API Credentials**
   - Go to Settings → API
   - Copy **Project URL** and **anon key**
   - Update `lib/config/supabase_config.dart`:
     ```dart
     static const String supabaseUrl = 'YOUR_PROJECT_URL';
     static const String supabaseAnonKey = 'YOUR_ANON_KEY';
     ```

### Step 2: Database Setup (3 min)

1. **Run Setup Script**
   - Open Supabase SQL Editor
   - Copy contents of `supabase_complete_setup.sql`
   - Paste and run (Ctrl+Enter)
   - Verify: No errors, tables created

### Step 3: Create Test Users (4 min)

1. **Create Users in Auth UI**
   - Go to Authentication → Users → Add User
   - Create HR user:
     - Email: `hr@apexnuera.com`
     - Password: (your choice)
     - ✅ Auto Confirm User
   - Create Employee user:
     - Email: `employee@apexnuera.com`
     - Password: (your choice)
     - ✅ Auto Confirm User

2. **Assign Roles**
   - Open SQL Editor
   - Copy contents of `supabase_quick_start.sql`
   - Paste and run
   - Verify: Users have roles assigned

### Step 4: Test the App (3 min)

1. **Run the App**
   ```bash
   flutter pub get
   flutter run -d chrome
   ```

2. **Test HR Login**
   - Navigate to Login → HR Login
   - Email: `hr@apexnuera.com`
   - Password: (your password)
   - ✅ Should redirect to HR Dashboard

3. **Test Employee Login**
   - Navigate to Login → Employee Login
   - Email: `employee@apexnuera.com`
   - Password: (your password)
   - ✅ Should redirect to Employee Dashboard

---

## 🎯 What You Get

### ✅ Authentication Features
- [x] Secure email/password authentication
- [x] Role-based access control (HR vs Employee)
- [x] Protected routes (can't access without login)
- [x] Automatic role verification
- [x] Session management
- [x] Logout functionality

### ✅ User Roles
- **HR Users**: Access to HR dashboard, employee management, job posting
- **Employee Users**: Access to employee dashboard, profile, timesheet, compensation

### ✅ Security
- [x] Row Level Security (RLS) enabled
- [x] Users can only see their own data
- [x] HR can see all employee data
- [x] Role-based route protection
- [x] Secure password storage (Supabase Auth)

---

## 📁 Project Structure

```
Portal_Company/
├── lib/
│   ├── config/
│   │   └── supabase_config.dart          # ⚙️ Supabase credentials
│   ├── services/
│   │   └── auth_service.dart             # 🔐 Authentication logic
│   ├── pages/
│   │   ├── hr_login_page_clean.dart      # 👔 HR login UI
│   │   ├── employee_login_page.dart      # 👤 Employee login UI
│   │   ├── hr_dashboard_page.dart        # 📊 HR dashboard
│   │   └── employee_dashboard_page.dart  # 📋 Employee dashboard
│   └── main.dart                         # 🚀 App entry & routing
├── supabase_complete_setup.sql           # 🗄️ Database setup
├── supabase_quick_start.sql              # ⚡ Quick user creation
├── SUPABASE_SETUP_GUIDE.md               # 📖 Detailed guide
├── SUPABASE_CHECKLIST.md                 # ✅ Setup checklist
├── AUTHENTICATION_FLOW.md                # 🔄 Flow diagrams
└── README_SUPABASE.md                    # 📄 This file
```

---

## 🔧 Configuration Files

### 1. Supabase Config (`lib/config/supabase_config.dart`)
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://xxxxx.supabase.co';
  static const String supabaseAnonKey = 'eyJ...';
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
}
```

### 2. Auth Service (`lib/services/auth_service.dart`)
```dart
class AuthService extends ChangeNotifier {
  // Singleton instance
  static final AuthService instance = AuthService._internal();
  
  // Sign in with email and password
  Future<String?> signInWithEmail(String email, String password, {required bool isHR});
  
  // Sign out
  Future<void> signOut();
  
  // Get current user
  User? getCurrentUser();
}
```

---

## 🗄️ Database Schema

### user_roles Table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key, references auth.users |
| role | TEXT | 'hr' or 'employee' |
| email | TEXT | User's email |
| created_at | TIMESTAMPTZ | Role assignment date |
| updated_at | TIMESTAMPTZ | Last update date |

### employee_profiles Table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key, references auth.users |
| email | TEXT | Employee email |
| full_name | TEXT | Full name |
| employee_id | TEXT | Unique employee ID |
| department | TEXT | Department name |
| position | TEXT | Job title |
| ... | ... | (more fields) |

---

## 🧪 Testing Checklist

- [ ] HR user can login at `/login/hr`
- [ ] Employee user can login at `/login/employee`
- [ ] HR user redirected to `/hr/dashboard`
- [ ] Employee user redirected to `/employee/dashboard`
- [ ] HR credentials rejected on employee login
- [ ] Employee credentials rejected on HR login
- [ ] Cannot access `/hr/dashboard` without HR login
- [ ] Cannot access `/employee/dashboard` without employee login
- [ ] Logout works correctly
- [ ] Invalid credentials show error message

---

## 🐛 Common Issues & Solutions

### Issue: "Invalid login credentials"
**Solution**: Verify user exists in Supabase Auth UI and "Auto Confirm User" was checked.

### Issue: "Access denied"
**Solution**: Check user has role in `user_roles` table:
```sql
SELECT * FROM user_roles WHERE email = 'your@email.com';
```

### Issue: "Error fetching user role"
**Solution**: Re-run `supabase_complete_setup.sql` to fix RLS policies.

### Issue: App crashes on startup
**Solution**: Verify credentials in `lib/config/supabase_config.dart` are correct.

---

## 📞 Need Help?

1. **Check the detailed guide**: [SUPABASE_SETUP_GUIDE.md](SUPABASE_SETUP_GUIDE.md)
2. **Use the checklist**: [SUPABASE_CHECKLIST.md](SUPABASE_CHECKLIST.md)
3. **Understand the flow**: [AUTHENTICATION_FLOW.md](AUTHENTICATION_FLOW.md)
4. **Supabase Docs**: [supabase.com/docs](https://supabase.com/docs)
5. **Flutter Docs**: [flutter.dev/docs](https://flutter.dev/docs)

---

## 🎉 Next Steps

After completing the setup:

1. **Add More Users**
   - Create additional HR and employee accounts
   - Assign appropriate roles

2. **Customize Dashboards**
   - Modify `hr_dashboard_page.dart`
   - Modify `employee_dashboard_page.dart`

3. **Add Features**
   - Employee management
   - Timesheet tracking
   - Compensation management
   - Job posting

4. **Production Deployment**
   - Use environment variables for credentials
   - Enable email confirmation
   - Set up custom email templates
   - Configure password policies

---

## 📊 Quick Reference

### Login URLs
- HR: `http://localhost:PORT/login/hr`
- Employee: `http://localhost:PORT/login/employee`

### Test Credentials
- HR: `hr@apexnuera.com` / (your password)
- Employee: `employee@apexnuera.com` / (your password)

### Important Commands
```bash
# Install dependencies
flutter pub get

# Run app
flutter run -d chrome

# Clean build
flutter clean && flutter pub get
```

### Useful SQL Queries
```sql
-- View all users with roles
SELECT u.email, ur.role FROM auth.users u
LEFT JOIN user_roles ur ON u.id = ur.id;

-- Assign role to user
INSERT INTO user_roles (id, role, email)
SELECT id, 'hr', email FROM auth.users WHERE email = 'user@example.com';
```

---

**Setup Time**: ~15 minutes  
**Difficulty**: Easy  
**Prerequisites**: Supabase account, Flutter SDK  
**Last Updated**: November 2025

---

## ✅ Setup Complete!

You now have a fully functional authentication system with role-based access control!

🎯 **Test it now**: Run `flutter run -d chrome` and try logging in!
