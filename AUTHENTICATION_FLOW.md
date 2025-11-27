# Supabase Authentication Flow Diagram

## 🔄 Complete Authentication Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER JOURNEY                                 │
└─────────────────────────────────────────────────────────────────────┘

1. HOMEPAGE (/)
   │
   ├─→ Click "Login" Button
   │
   ├─→ LOGIN PAGE (/login)
       │
       ├─→ Select "HR Login" ──────────→ HR LOGIN PAGE (/login/hr)
       │                                  │
       │                                  ├─→ Enter Credentials
       │                                  │   (email, password)
       │                                  │
       │                                  ├─→ AuthService.signInWithEmail()
       │                                  │   - isHR: true
       │                                  │
       │                                  ├─→ Supabase Auth
       │                                  │   - Verify credentials
       │                                  │   - Return user object
       │                                  │
       │                                  ├─→ Fetch user role from user_roles table
       │                                  │   - Query: SELECT role WHERE id = user.id
       │                                  │
       │                                  ├─→ Verify role = 'hr'
       │                                  │   │
       │                                  │   ├─→ ✅ Success: role = 'hr'
       │                                  │   │   - Set isHRLoggedIn = true
       │                                  │   │   - Navigate to /hr/dashboard
       │                                  │   │
       │                                  │   └─→ ❌ Fail: role != 'hr'
       │                                  │       - Sign out user
       │                                  │       - Show error: "Access denied"
       │                                  │
       │                                  └─→ HR DASHBOARD (/hr/dashboard)
       │                                      - Overview
       │                                      - Employee Management
       │                                      - Post Jobs/Internships
       │                                      - Queries & Alerts
       │
       └─→ Select "Employee Login" ───→ EMPLOYEE LOGIN PAGE (/login/employee)
                                         │
                                         ├─→ Enter Credentials
                                         │   (email, password)
                                         │
                                         ├─→ AuthService.signInWithEmail()
                                         │   - isHR: false
                                         │
                                         ├─→ Supabase Auth
                                         │   - Verify credentials
                                         │   - Return user object
                                         │
                                         ├─→ Fetch user role from user_roles table
                                         │   - Query: SELECT role WHERE id = user.id
                                         │
                                         ├─→ Verify role = 'employee'
                                         │   │
                                         │   ├─→ ✅ Success: role = 'employee'
                                         │   │   - Set isEmployeeLoggedIn = true
                                         │   │   - Update AppSession
                                         │   │   - Navigate to /employee/dashboard
                                         │   │
                                         │   └─→ ❌ Fail: role != 'employee'
                                         │       - Sign out user
                                         │       - Show error: "Access denied"
                                         │
                                         └─→ EMPLOYEE DASHBOARD (/employee/dashboard)
                                             - Personal Profile
                                             - Professional Profile
                                             - Timesheet
                                             - Compensation
                                             - FAQs
```

---

## 🗄️ Database Structure

```
┌──────────────────────────────────────────────────────────────┐
│                     auth.users (Supabase Auth)               │
├──────────────────────────────────────────────────────────────┤
│ id (UUID)         │ Primary Key                              │
│ email             │ User's email address                     │
│ encrypted_password│ Hashed password                          │
│ created_at        │ Account creation timestamp               │
│ confirmed_at      │ Email confirmation timestamp             │
└──────────────────────────────────────────────────────────────┘
                              │
                              │ References
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                     user_roles (Custom Table)                │
├──────────────────────────────────────────────────────────────┤
│ id (UUID)         │ FK → auth.users.id (ON DELETE CASCADE)   │
│ role (TEXT)       │ 'hr' or 'employee'                       │
│ email (TEXT)      │ User's email (for easy lookup)           │
│ created_at        │ Role assignment timestamp                │
│ updated_at        │ Last update timestamp                    │
└──────────────────────────────────────────────────────────────┘
                              │
                              │ References (for employees)
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                 employee_profiles (Custom Table)             │
├──────────────────────────────────────────────────────────────┤
│ id (UUID)         │ FK → auth.users.id (ON DELETE CASCADE)   │
│ email             │ Employee email                           │
│ full_name         │ Full name                                │
│ employee_id       │ Unique employee ID (e.g., EMP001)        │
│ department        │ Department name                          │
│ position          │ Job title                                │
│ phone             │ Contact number                           │
│ date_of_birth     │ Birth date                               │
│ date_of_joining   │ Joining date                             │
│ manager_id        │ FK → employee_profiles.id (optional)     │
│ ... (more fields) │                                          │
└──────────────────────────────────────────────────────────────┘
```

---

## 🔒 Row Level Security (RLS) Policies

### user_roles Table

```
Policy: "Users can read their own role"
  ├─ Operation: SELECT
  ├─ Condition: auth.uid() = id
  └─ Effect: Users can only see their own role

Policy: "Authenticated users can read all roles"
  ├─ Operation: SELECT
  ├─ Condition: auth.role() = 'authenticated'
  └─ Effect: Any authenticated user can see all roles
              (needed for HR to view employee roles)

Policy: "Service role can manage user roles"
  ├─ Operation: ALL (INSERT, UPDATE, DELETE)
  ├─ Condition: auth.jwt() ->> 'role' = 'service_role'
  └─ Effect: Only service accounts can modify roles
```

### employee_profiles Table

```
Policy: "Users can read their own profile"
  ├─ Operation: SELECT
  ├─ Condition: auth.uid() = id
  └─ Effect: Employees can see their own profile

Policy: "HR can read all profiles"
  ├─ Operation: SELECT
  ├─ Condition: EXISTS (SELECT 1 FROM user_roles 
  │                     WHERE id = auth.uid() AND role = 'hr')
  └─ Effect: HR users can see all employee profiles

Policy: "HR can manage profiles"
  ├─ Operation: ALL (INSERT, UPDATE, DELETE)
  ├─ Condition: EXISTS (SELECT 1 FROM user_roles 
  │                     WHERE id = auth.uid() AND role = 'hr')
  └─ Effect: HR users can create/update/delete profiles
```

---

## 🛣️ Route Protection (GoRouter)

```
┌─────────────────────────────────────────────────────────────┐
│                    Route Protection Logic                    │
└─────────────────────────────────────────────────────────────┘

GoRouter Redirect Middleware:
  │
  ├─→ Check if route starts with '/hr'
  │   │
  │   ├─→ YES: Is user HR logged in?
  │   │   │
  │   │   ├─→ YES: Allow access
  │   │   └─→ NO: Redirect to /login/hr
  │   │
  │   └─→ NO: Continue
  │
  ├─→ Check if route starts with '/employee'
  │   │
  │   ├─→ YES: Is user Employee logged in?
  │   │   │
  │   │   ├─→ YES: Allow access
  │   │   └─→ NO: Redirect to /login/employee
  │   │
  │   └─→ NO: Continue
  │
  └─→ Allow access to public routes
```

---

## 📊 State Management

```
┌─────────────────────────────────────────────────────────────┐
│                    AuthService (Singleton)                   │
├─────────────────────────────────────────────────────────────┤
│ State:                                                       │
│   - _currentUser: User?                                      │
│   - _userRole: String? ('hr' or 'employee')                  │
│   - _isHRLoggedIn: bool                                      │
│   - _isEmployeeLoggedIn: bool                                │
│                                                              │
│ Methods:                                                     │
│   - signInWithEmail(email, password, isHR)                   │
│   - signOut()                                                │
│   - getCurrentUser()                                         │
│   - _fetchUserRole(userId)                                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Extends ChangeNotifier
                              │ (notifies listeners on state change)
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Provider (in main.dart)                   │
├─────────────────────────────────────────────────────────────┤
│ ChangeNotifierProvider<AuthService>                         │
│   - Provides AuthService.instance to entire app             │
│   - Widgets can listen to auth state changes                │
│   - GoRouter refreshes on auth state change                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 Security Flow

```
1. User submits credentials
   │
   ├─→ 2. AuthService.signInWithEmail()
       │
       ├─→ 3. Supabase.auth.signInWithPassword()
           │
           ├─→ 4. Supabase validates credentials
               │
               ├─→ ✅ Valid
               │   │
               │   ├─→ 5. Return User object with JWT token
               │       │
               │       ├─→ 6. Fetch role from user_roles table
               │           │   (using RLS - user can only see their own role)
               │           │
               │           ├─→ 7. Verify role matches expected role
               │               │
               │               ├─→ ✅ Match
               │               │   │
               │               │   ├─→ 8. Set login flags
               │               │   ├─→ 9. Store user in state
               │               │   └─→ 10. Navigate to dashboard
               │               │
               │               └─→ ❌ Mismatch
               │                   │
               │                   ├─→ 8. Sign out user
               │                   └─→ 9. Show error message
               │
               └─→ ❌ Invalid
                   │
                   └─→ 5. Return error message
                       │
                       └─→ 6. Display error to user
```

---

## 🎯 Key Components

### Frontend (Flutter)
```
lib/
├── config/
│   └── supabase_config.dart       # Supabase credentials & initialization
├── services/
│   └── auth_service.dart          # Authentication logic
├── pages/
│   ├── hr_login_page_clean.dart   # HR login UI
│   ├── employee_login_page.dart   # Employee login UI
│   ├── hr_dashboard_page.dart     # HR dashboard
│   └── employee_dashboard_page.dart # Employee dashboard
├── state/
│   └── app_session.dart           # App-wide state management
└── main.dart                      # App entry point & routing
```

### Backend (Supabase)
```
Supabase Project
├── Authentication (auth.users)    # User accounts
├── Database
│   ├── user_roles                 # Role assignments
│   └── employee_profiles          # Employee data
├── Row Level Security             # Access control policies
└── SQL Functions                  # Helper functions
```

---

## 🚀 Quick Reference

### Login Endpoints
- HR Login: `/login/hr`
- Employee Login: `/login/employee`

### Protected Routes
- HR Dashboard: `/hr/dashboard`
- Employee Dashboard: `/employee/dashboard`

### Role Values
- HR: `'hr'`
- Employee: `'employee'`

### Auth State
- Check if logged in: `AuthService.instance.isAuthenticated`
- Get current user: `AuthService.instance.currentUser`
- Get user role: `AuthService.instance.userRole`

---

**Last Updated**: November 2025
