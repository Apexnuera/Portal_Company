# Employee Tables Migration Note

## Issue Resolved
The `EmployeeManagementService` was referencing the old `employees` table, but the new schema uses `employee_profiles`.

## Changes Made
Updated all references in `lib/services/employee_management_service.dart`:
- ✅ `createEmployee()`: Now inserts into `employee_profiles` with correct field names (`full_name`, `corporate_email`)
- ✅ `getEmployees()`: Now queries from `employee_profiles`
- ✅ `updateEmployee()`: Now updates `employee_profiles`
- ✅ `deleteEmployee()`: Now deletes from `employee_profiles`

## Table Comparison

### Old Schema (supabase_employees_setup.sql)
```sql
CREATE TABLE employees (
  id UUID PRIMARY KEY,
  auth_user_id UUID,
  employee_id TEXT,
  name TEXT,        -- OLD field name
  email TEXT,       -- OLD field name
  ...
);
```

### New Schema (employee_profiles_schema.sql)
```sql
CREATE TABLE employee_profiles (
  id UUID PRIMARY KEY,
  auth_user_id UUID,
  employee_id TEXT,
  full_name TEXT,           -- NEW field name
  corporate_email TEXT,     -- NEW field name
  personal_email TEXT,      -- NEW field
  ... (many more fields)
);
```

## Why the Change?
The new `employee_profiles` table includes:
- ✅ Complete personal details (address, DOB, blood group, etc.)
- ✅ Professional details (position, department, etc.)
- ✅ Compensation data (salary, allowances)
- ✅ Bank details
- ✅ Current project information
- ✅ Related tables for education, employment history, projects, documents

The old `employees` table only had basic info (ID, name, email).

## Important Notes

### If you already ran `supabase_employees_setup.sql`:
The new schema will **replace** the old `employees` table with `employee_profiles`. This is intentional and correct.

### Old SQL File
The file `supabase_employees_setup.sql` is now **deprecated**. Use `employee_profiles_schema.sql` instead.

### Data Migration
If you had test data in the old `employees` table, it will be lost when you run the new schema (which drops the old table). This is fine for development.

For production migration, you would:
1. Export data from `employees` table
2. Run new schema
3. Import data into `employee_profiles` with field mapping

## Verification

After running `employee_profiles_schema.sql`, verify:

```sql
-- Check table exists
SELECT * FROM employee_profiles LIMIT 1;

-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'employee_profiles';

-- Check related tables
SELECT * FROM project_allocations LIMIT 1;
SELECT * FROM education_entries LIMIT 1;
SELECT * FROM employment_entries LIMIT 1;
SELECT * FROM compensation_documents LIMIT 1;
```

## Next Steps

1. ✅ **Service updated** - `EmployeeManagementService` now uses correct table
2. ⚠️ **SQL needed** - Run `employee_profiles_schema.sql` in Supabase
3. ✅ **App ready** - Hot reload and test employee creation

Once you run the SQL, you can create employees through the HR Dashboard!
