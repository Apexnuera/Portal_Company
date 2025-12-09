# Fix for Job Creation Issues

## Issues Identified
1. **null value in column "id"** - The `id` column may not have proper default value set
2. **reference_code column missing** - The column doesn't exist in the database
3. **permission denied for table users** - RLS policies preventing HR from reading user_roles

## Solution

### Step 1: Execute SQL Fix in Supabase

1. Go to **Supabase Dashboard**: https://supabase.com/dashboard
2. Select your project: **utjihkmkmzzerhokpvps**
3. Click **SQL Editor** in the left sidebar
4. Click **New Query**
5. Copy and paste the contents of `supabase_complete_fix.sql`
6. Click **Run** to execute

This will:
- Add `reference_code` columns to `jobs` and `internships` tables
- Ensure `id` columns have proper UUID auto-generation defaults
- Fix RLS policies to allow HR users to read the `user_roles` table
- Grant necessary permissions

### Step 2: Code Changes (Already Applied)

The following Dart code changes have been made to `post_store.dart`:

1. **JobPost.toJson()** - Now excludes `reference_code` if it's null
2. **InternshipPost.toJson()** - Now excludes `reference_code` if it's null

This prevents sending explicit `null` values to Supabase, which can cause issues with some database configurations.

### Step 3: Test

After running the SQL:

1. **Hot restart** your Flutter app (press `R` in the terminal or restart the debug session)
2. Try creating a new job posting
3. The errors should be resolved

## Verification

After running the SQL, you can verify the changes by running this query in Supabase SQL Editor:

```sql
-- Check id column defaults
SELECT 
  table_name,
  column_name,
  column_default,
  is_nullable
FROM information_schema.columns
WHERE table_name IN ('jobs', 'internships')
  AND column_name IN ('id', 'reference_code')
ORDER BY table_name, column_name;
```

You should see:
- `id` columns with default: `gen_random_uuid()`
- `reference_code` columns with default: `NULL`

## Expected Results

After applying these fixes:
- ✅ Jobs can be created without errors
- ✅ Internships can be created without errors
- ✅ HR users can read user_roles table
- ✅ Reference codes are optional and work correctly
