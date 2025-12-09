# Employee Details - Supabase Integration

## Overview
The Employee Details system is now fully integrated with Supabase, enabling complete employee lifecycle management from HR creation to employee profile updates.

## Complete Workflow

### 1. HR Creates Employee
**Where**: HR Dashboard → Employee Details Section  
**What Happens**:
1. HR fills in basic employee information:
   - Employee ID
   - Full Name
   - Corporate Email
   - Password (for login)
2. System creates:
   - Supabase Auth account
   - User role entry (employee)
   - Employee profile record

**Backend Process**:
```
HR Input → EmployeeManagementService.createEmployee()
   ↓
Supabase Auth.signUp() → Create auth user
   ↓
Insert into user_roles → Role assignment
   ↓
Insert into employee_profiles → Profile creation
   ↓
Success! Employee can now log in
```

### 2. Employee Logs In
**Where**: Employee Login Page (`/employee-login`)  
**Credentials**: Email + Password provided by HR  
**What Happens**:
1. Employee enters credentials
2. Supabase authenticates the user
3. System fetches employee role
4. Redirects to Employee Dashboard

### 3. Employee Updates Profile
**Where**: Employee Dashboard → Profile Section  
**What Can Be Updated**:
- Personal Details (address, phone, DOB, etc.)
- Professional Profile (education, employment history)
- Bank Details (for salary)
- Project Allocations
- Document Uploads

**Backend Process**:
```
Employee Updates → EmployeeProfileService.updateXXX()
   ↓
Update employee_profiles table
   ↓
Update related tables (education, employment, etc.)
   ↓
Realtime sync across all open sessions
```

## Database Schema

### Main Tables

#### 1. `employee_profiles`
**Purpose**: Stores complete employee information  
**Key Fields**:
- Identity: `id`, `auth_user_id`, `employee_id`
- Personal: `full_name`, `corporate_email`, `mobile_number`, etc.
- Professional: `position`, `department`, `employment_type`, etc.
- Compensation: `basic_salary`, `gross_salary`, `net_salary`
- Metadata: `created_at`, `updated_at`, `created_by`

#### 2. `project_allocations`
**Purpose**: Track employee project assignments  
**Fields**: `project_name`, `duration`, `reporting_manager`

#### 3. `education_entries`
**Purpose**: Store education qualifications  
**Fields**: `level_of_education`, `institution`, `degree`, `year`, `grade`

#### 4. `employment_entries`
**Purpose**: Track employment history  
**Fields**: `company_name`, `designation`, `from_date`, `to_date`

#### 5. `compensation_documents`
**Purpose**: Store compensation-related documents  
**Types**: Payslips, Offer Letters, Bonuses, Reimbursements, etc.

### Storage Buckets

#### 1. `employee-profiles`
**Contents**: Profile images  
**Access**:
- HR: Full access
- Employees: Can view/upload own image

#### 2. `employee-documents`
**Contents**: Education and employment documents  
**Access**:
- HR: Full access
- Employees: Can manage own documents

#### 3. `compensation-docs`
**Contents**: Salary, bonus, and benefit documents  
**Access**:
- HR: Full access
- Employees: Can view own documents only

## Security (RLS Policies)

### HR Permissions
- ✅ **CREATE**: Can create new employee profiles
- ✅ **READ**: Can view all employee profiles
- ✅ **UPDATE**: Can update any employee data
- ✅ **DELETE**: Can delete employee profiles

### Employee Permissions
- ❌ **CREATE**: Cannot create profiles
- ✅ **READ**: Can view own profile only
- ✅ **UPDATE**: Can update own profile only
- ❌ **DELETE**: Cannot delete profiles

### Specific Restrictions
- **Compensation Data**: HR can update, employees can view only
- **Profile Images**: Both can upload/view own
- **Documents**: Employees can upload own, HR can upload for anyone

## Services

### 1. EmployeeManagementService
**Purpose**: HR-only service for employee creation  
**Key Methods**:
- `createEmployee()`: Create new employee with auth account
- `getEmployees()`: Get all employees (HR view)
- `updateEmployee()`: Update employee data
- `deleteEmployee()`: Remove employee

### 2. EmployeeProfileService
**Purpose**: Manage complete employee profiles  
**Key Methods**:
- `initialize()`: Load current user's profile
- `updatePersonalDetails()`: Update personal info
- `updateProfessionalProfile()`: Update work info
- `updateCompensation()`: Update salary data
- `uploadProfileImage()`: Upload profile picture
- `addCompensationDocument()`: Add salary/bonus documents

### 3. EmployeeDirectory (State)
**Purpose**: Local state management for employee data  
**Usage**: Bridges between Supabase and UI components

## Setup Instructions

### Step 1: Run SQL Schema
Execute in Supabase SQL Editor:
```bash
# Run this file first (if not already done)
supabase_user_roles_policy_v2.sql

# Then run the employee schema
employee_profiles_schema.sql
```

This creates:
- All employee-related tables
- RLS policies
- Storage buckets
- Indexes and triggers

### Step 2: Verify Setup
Check in Supabase Dashboard:
1. **Tables**: Verify 5 tables exist
   - employee_profiles
   - project_allocations
   - education_entries
   - employment_entries
   - compensation_documents

2. **Storage**: Verify 3 buckets exist
   - employee-profiles
   - employee-documents
   - compensation-docs

3. **Policies**: Check RLS policies are active

### Step 3: Test the Flow

#### As HR:
1. Log in as HR user
2. Go to Employee Details section
3. Create a new employee:
   - Employee ID: `EMP001`
   - Name: `Test Employee`
   - Email: `test@company.com`
   - Password: `Test@123`
4. Verify success message

#### As Employee:
1. Log out from HR
2. Go to Employee Login page
3. Log in with employee credentials
4. Verify Employee Dashboard loads
5. Update profile information
6. Verify changes are saved

## Data Flow Diagrams

### Employee Creation Flow
```
HR Dashboard
    ↓
[Create Employee Form]
    ↓
EmployeeManagementService.createEmployee()
    ↓
┌─────────────────────────────────────┐
│ 1. Create Auth User                │
│    - Supabase Auth.signUp()        │
│    - Email: test@company.com       │
│    - Password: Test@123            │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ 2. Assign Role                     │
│    - Insert into user_roles        │
│    - Role: 'employee'              │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ 3. Create Profile                  │
│    - Insert into employee_profiles │
│    - Basic info only               │
└─────────────────────────────────────┘
    ↓
Success! Employee can log in
```

### Employee Login Flow
```
Employee Login Page
    ↓
[Enter Credentials]
    ↓
Supabase Auth.signInWithPassword()
    ↓
┌─────────────────────────────────────┐
│ Authentication Successful          │
│ - User ID: xxx-xxx-xxx             │
│ - Email: test@company.com          │
└─────────────────────────────────────┘
    ↓
AuthService.fetchUserRole()
    ↓
┌─────────────────────────────────────┐
│ Fetch from user_roles              │
│ - Role: 'employee'                 │
└─────────────────────────────────────┘
    ↓
EmployeeProfileService.initialize()
    ↓
┌─────────────────────────────────────┐
│ Load Complete Profile              │
│ - Personal details                 │
│ - Professional info                │
│ - Compensation data                │
│ - Related tables                   │
└─────────────────────────────────────┘
    ↓
Navigate to Employee Dashboard
```

### Profile Update Flow
```
Employee Dashboard → Profile Section
    ↓
[Update Form] (e.g., Personal Details)
    ↓
EmployeeProfileService.updatePersonalDetails()
    ↓
┌─────────────────────────────────────┐
│ Update employee_profiles           │
│ - Main profile data                │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Update Related Tables              │
│ - project_allocations              │
│ - education_entries                │
│ - employment_entries               │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Realtime Sync                      │
│ - All open sessions updated        │
└─────────────────────────────────────┘
    ↓
UI Auto-refreshes with new data
```

## Key Features

### ✅ Implemented
1. **Employee Creation by HR**
   - Auth account creation
   - Role assignment
   - Profile initialization

2. **Employee Authentication**
   - Login with email/password
   - Role-based access control

3. **Profile Management**
   - Personal details updates
   - Professional info updates
   - Bank details
   - Project allocations
   - Education history
   - Employment history

4. **Document Management**
   - Profile image upload
   - Compensation documents
   - Education certificates
   - Employment letters

5. **Security**
   - Row Level Security (RLS)  
   - HR-only create/delete
   - Employee can update own data only

6. **Realtime Updates**
   - Live sync across sessions
   - Immediate data reflection

### 🚀 Advanced Features
- **Cascade Delete**: Deleting employee removes all related data
- **Automatic Timestamps**: Created/updated times tracked
- **Storage Integration**: Files stored securely in Supabase
- **Type Safety**: Full TypeScript/Dart type support

## Troubleshooting

### Employee Creation Fails
**Check**:
- Is HR user logged in?
- Does user have HR role in user_roles table?
- Is email already in use?
- Are RLS policies set up correctly?

**Debug**:
```sql
-- Check if user has HR role
SELECT * FROM user_roles WHERE id = 'YOUR_USER_ID';

-- Check existing employees
SELECT * FROM employee_profiles;
```

### Employee Cannot Log In
**Check**:
- Are credentials correct?
- Does auth user exist?
- Is email verified (if email verification is enabled)?

**Debug**:
```sql
-- Check if auth user exists
SELECT * FROM auth.users WHERE email = 'employee@company.com';

-- Check if employee profile exists
SELECT * FROM employee_profiles WHERE corporate_email = 'employee@company.com';
```

### Profile Updates Not Saving
**Check**:
- Is employee logged in?
- Does employee have profile in database?
- Are RLS policies allowing updates?

**Debug**:
```sql
-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'employee_profiles';

-- Test policy manually
SET request.jwt.claims = '{"sub": "YOUR_USER_ID"}';
SELECT * FROM employee_profiles WHERE auth_user_id = auth.uid();
```

### Documents Not Uploading
**Check**:
- Does storage bucket exist?
- Are storage policies set up?
- Is file size within limits?

**Debug**:
```sql
-- Check storage buckets
SELECT * FROM storage.buckets;

-- Check storage policies
SELECT * FROM storage.objects WHERE bucket_id = 'employee-profiles';
```

## Migration Notes

### From Local to Supabase
**Before**: Employee data stored in `EmployeeDirectory` (in-memory)  
**After**: Employee data stored in Supabase (persistent)

**Breaking Changes**: None! The UI and workflow remain the same.

**Data Migration**: 
- Existing local data is not migrated automatically
- HR must re-create employees through the portal
- Employees must re-enter their profile information

## Future Enhancements

Possible improvements:
- [ ] Bulk employee import (CSV upload)
- [ ] Email notifications on profile creation
- [ ] Employee status (active/inactive/resigned)
- [ ] Performance reviews and feedback
- [ ] Leave management integration
- [ ] Attendance tracking
- [ ] Organization chart visualization
- [ ] Employee search and filtering
- [ ] Export employee data (PDF reports)
- [ ] Audit logs for profile changes

## Summary

The Employee Details system now provides:
- ✅ **Complete Employee Lifecycle**: From HR creation to employee updates
- ✅ **Secure Authentication**: Supabase Auth integration
- ✅ **Role-Based Access**: HR vs Employee permissions
- ✅ **Comprehensive Profiles**: Personal, professional, compensation data
- ✅ **Document Management**: Secure file storage
- ✅ **Realtime Sync**: Instant updates across sessions
- ✅ **Production-Ready**: RLS, indexes, triggers all configured

This is a **production-grade employee management system** ready for real-world use!
