-- Fix Document Access for HR and Employees
-- This script updates Storage RLS policies to ensure:
-- 1. Employees can read/write their own documents.
-- 2. HR can read/write ALL documents.

-- Enable RLS on storage.objects (if not already enabled)
-- ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts (optional, safe to run if they don't exist)
DROP POLICY IF EXISTS "Employee Documents Access" ON storage.objects;
DROP POLICY IF EXISTS "Compensation Documents Access" ON storage.objects;
DROP POLICY IF EXISTS "HR Full Access Storage" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder 1ok12a_0" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder 1ok12a_1" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder 1ok12a_2" ON storage.objects;
DROP POLICY IF EXISTS "Give users access to own folder 1ok12a_3" ON storage.objects;

-- 1. Policy for 'employee-documents' bucket
-- Bucket stores files as: <profile_id>/<category>/<timestamp>_<filename>
-- profile_id is the UUID from employee_profiles table.
CREATE POLICY "Employee Documents Access"
ON storage.objects
FOR ALL
USING (
  bucket_id = 'employee-documents'
  AND (
    -- HR has full access
    (SELECT role FROM public.user_roles WHERE id = auth.uid() LIMIT 1) = 'hr'
    OR
    -- Employee can access their own folder (folder name must match their profile ID)
    (storage.foldername(name))[1] IN (
      SELECT id::text 
      FROM public.employee_profiles 
      WHERE auth_user_id = auth.uid()
    )
  )
)
WITH CHECK (
  bucket_id = 'employee-documents'
  AND (
    -- HR has full access
    (SELECT role FROM public.user_roles WHERE id = auth.uid() LIMIT 1) = 'hr'
    OR
    -- Employee can upload to their own folder
    (storage.foldername(name))[1] IN (
      SELECT id::text 
      FROM public.employee_profiles 
      WHERE auth_user_id = auth.uid()
    )
  )
);

-- 2. Policy for 'compensation-docs' bucket
-- Bucket stores files as: <AuthUID>/<filename> OR <EmployeeID>/<filename>
-- We need to cover both cases.
CREATE POLICY "Compensation Documents Access"
ON storage.objects
FOR ALL
USING (
  bucket_id = 'compensation-docs'
  AND (
    -- HR has full access
    (SELECT role FROM public.user_roles WHERE id = auth.uid() LIMIT 1) = 'hr'
    OR
    -- Case 1: Folder is Auth UID (Employee upload)
    (storage.foldername(name))[1] = auth.uid()::text
    OR
    -- Case 2: Folder is Employee ID (HR upload for employee)
    (storage.foldername(name))[1] IN (
      SELECT employee_id 
      FROM public.employee_profiles 
      WHERE auth_user_id = auth.uid()
    )
  )
)
WITH CHECK (
  bucket_id = 'compensation-docs'
  AND (
    -- HR has full access
    (SELECT role FROM public.user_roles WHERE id = auth.uid() LIMIT 1) = 'hr'
    OR
    -- Case 1: Folder is Auth UID (Employee upload)
    (storage.foldername(name))[1] = auth.uid()::text
    -- Note: Employees generally don't upload to EmployeeID folder, only HR does.
  )
);

-- 3. Ensure 'employee-profiles' Bucket (Profile Pictures) is readable by everyone
-- (Or at least authenticated users)
CREATE POLICY "Profile Images Access"
ON storage.objects
FOR SELECT
USING (
  bucket_id = 'employee-profiles'
  -- Assume authenticatd users can see all profile pics
  AND auth.role() = 'authenticated'
);

-- Allow users to upload their own profile picture
CREATE POLICY "Profile Images Upload"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'employee-profiles'
  AND (
    -- HR
    (SELECT role FROM public.user_roles WHERE id = auth.uid() LIMIT 1) = 'hr'
    OR
    -- Owner
    (storage.foldername(name))[1] = auth.uid()::text
  )
);

-- Allow users to update/delete their own profile picture
CREATE POLICY "Profile Images Update"
ON storage.objects
FOR UPDATE
USING (
  bucket_id = 'employee-profiles'
  AND (
    (SELECT role FROM public.user_roles WHERE id = auth.uid() LIMIT 1) = 'hr'
    OR
    (storage.foldername(name))[1] = auth.uid()::text
  )
);
